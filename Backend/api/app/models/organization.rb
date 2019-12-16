require_relative 'model_base'

module Models
  class Organization
    include ModelBase

    class << self
      alias :dynamoDB_find :find

      def find(id)
        dynamoDB_find(primary_key: id, sort_key: 'organization')
      end
    end
  end
end
