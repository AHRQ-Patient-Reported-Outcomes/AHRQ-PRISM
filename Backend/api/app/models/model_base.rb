# frozen_string_literal: true

require 'active_model'

module Models::ModelBase
  def self.included(base)
    base.class_eval do
      include Aws::Record
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
      include ActiveModel::Serialization

      before_validation :remove_blank_strings
      before_validation :enforce_value_types

      set_table_name ENV['DYNAMO_TABLE_NAME']

      string_attr :primary_key, hash_key: true, database_attribute_name: 'primaryKey'
      string_attr :sort_key, range_key: true, database_attribute_name: 'sortKey'

      time_attr :created_at, default_value: Time.now.utc
      time_attr :updated_at, default_value: Time.now.utc

      validates_presence_of :primary_key, :sort_key

      # Extend the dynamoDb save method to automatically set the updated_at
      # if we have mutated the record and will be persisting it. If we have not changed then
      # this would be a no-op and so we do not change updated_at
      alias_method :dynamo_save, :save

      # Set the local table if we're in development or test
      if $dynamo_local
        configure_client(client: $dynamo_local)
      end

      def save(opts = {})
        if !valid?
          raise Aws::Record::Errors::ValidationError.new(errors.full_messages)
        end

        if dirty? && !new_record?
          self.updated_at = Time.now
        end

        dynamo_save(opts) # original is `dynamo_save`
      end

      def to_json(*args)
        serializable_hash.to_json
      end

      def resource_type
        self.class.name.split('::').last
      end
      alias_method :resourceType, :resource_type
      def resourceType=(_); end

      def attributes
        raise 'implement me'
      end

      ##
      # For storing lists of other model classes, use this.
      # All operations happen on the underlying objects, which are serialized
      # and deserialized when saving and loading from DynamoDB.
      # If you edit the raw objects, those edits will *not* be saved.
      #
      # Creates methods of the plural form of the passed +name+ to operate on
      # the objects.
      def self.obj_list_attr(name, **opts)
        list_attr name

        self.class_eval do
          # call the old method to make sure the underlying data is set
          # properly
          alias_method "#{name}_raw", "#{name}"
          alias_method "#{name}_raw=", "#{name}="

          # make sure the underlying data is set before writing to dynamo
          before_validation "set_#{name}_from_obj"

          ##
          # Getter for raw content.
          #
          # Set raw from object if object is not nil.
          define_method(name.to_s) do
            obj = instance_variable_get("@obj_#{name}")
            return send("#{name}_raw") if obj.nil?
            send("set_#{name}_from_obj")
          end

          ##
          # Setter for raw content.
          #
          # Whenever this is called, create objects from the raw content.
          define_method("#{name}=") do |new_val|
            send("#{name}_raw=", new_val)
            send("set_obj_from_#{name}")
          end

          ##
          # Getter for objects.
          #
          # There are a few cases to handle here because of how `aws-record`
          # does things.
          #
          # * If object array is nil and raw isn't (after #find), object array
          #   is created from raw and returned
          # * Otherwise, return object array
          define_method(name.to_s.pluralize) do
            obj = instance_variable_get("@obj_#{name}")
            if obj.nil?
              raw = send(name)
              return send("set_obj_from_#{name}") if raw
            end

            obj
          end

          ##
          # Setter for objects.
          #
          # Sets both object and raw content.
          define_method("#{name.to_s.pluralize}=") do |new_val|
            tmp = instance_variable_set("@obj_#{name}", new_val)
            send("set_#{name}_from_obj")
            tmp
          end

          ##
          # Sets the raw content from objects.
          define_method("set_#{name}_from_obj") do
            obj = instance_variable_get("@obj_#{name}")
            return send("#{name}_raw=", nil) if obj.nil?
            send("#{name}_raw=", obj.map(&:serializable_hash))
          end

          ##
          # Initializes the objects from the raw content.
          #
          # This should *only* be called internally, and only if obj is nil
          # and raw isn't (e.g. after #find), or after raw= is done.
          define_method("set_obj_from_#{name}") do
            raw = send("#{name}_raw")
            return instance_variable_set("@obj_#{name}", nil) if raw.nil?

            tmp = []
            raw.map do |thing|
              thing = thing.map { |k, v| [k.to_sym, v] }.to_h

              if opts[:class_name]
                klass_name = opts[:class_name]
              elsif thing[:resourceType]
                klass_name = "Models::#{thing[:resourceType]}"
              end

              raise ArgumentError, "Can't decode #{thing}" if klass_name.nil?
              klass = "#{klass_name}".constantize
              tmp << klass.new(thing)
            end

            instance_variable_set("@obj_#{name}", tmp)
          end
        end
      end

      def sanitize!
        remove_blank_strings
        enforce_value_types
      end

      protected

      def is_blank?(field)
        return true if field.nil? || field == ''
      end

      def remove_blank_strings(thing = attributes)
        case thing.class.to_s
        when 'Hash'
          thing.each_with_object(thing) do |(k, v), h|
            h[k] = remove_blank_strings(v)
          end
        when 'Array'
          thing.each_index { |i| thing[i] = remove_blank_strings(thing[i]) }
        when 'String' then thing = nil if thing == ''
        end

        thing
      end

      ##
      # Make sure all `value[x]` thingies conform to FHIR.
      #
      # Promis is not perfectly FHIR compliant while Google is. For example,
      # Promis will return a `valueDate` that actually has a date-time in it.
      # That's real bad.
      #
      # This method runs before validation, finds every key that's a value, and
      # then renames it if it should be renamed.
      def enforce_value_types(hash = attributes)
        keys_to_manage = %i[valueDate valueDateTime valueDecimal valueInteger]

        keys = hash.keys
        keys.each do |k|
          v = hash[k]

          if v.is_a? Hash
            enforce_value_types(v)
            next
          elsif v.is_a? Array
            v.each { |item| enforce_value_types(item) if item.is_a? Hash }
            next
          end

          next unless keys_to_manage.include?(k.to_sym)

          case v
          when /^\d{4}-\d{2}-\d{2}$/ # date
            next if k == 'valueDate'
            hash.delete(k)
            hash['valueDate'] = v
          when /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(Z|((\+|-)\d{2}:\d{2}))$/ # dateTime
            next if k == 'valueDateTime'
            hash.delete(k)
            hash['valueDateTime'] = v
          else
            fix_formatting(hash, k)
          end
        end
      end

      def fix_formatting(hash, key)
        case key
        when 'valueDate'
          hash[key] = Date.parse(hash[key]).to_s
        when 'valueDateTime'
          hash[key] = DateTime.parse(hash[key]).to_s
        when 'valueDecimal'
          hash[key] = hash[key].to_f
        when 'valueInteger'
          hash[key] = hash[key].to_i
        end
      end
    end
  end
end
