require_relative 'model_base'
require_relative '../extensions/display_order'

class Models::Questionnaire
  include Models::ModelBase

  # persistent attributes
  map_attr :code
  list_attr :extension
  obj_list_attr :item, class_name: 'Models::Questionnaire::Item'
  map_attr :meta
  string_attr :name
  string_attr :title
  string_attr :description
  list_attr :subjectType
  string_attr :status

  # transient attributes
  attr_accessor :date
  attr_accessor :url

  alias_method :id, :primary_key
  alias_method :id=, :primary_key=

  before_validation :set_display_orders

  def self.find(id)
    query(
      key_condition_expression: 'primaryKey = :id AND sortKey = :sortValue',
      expression_attribute_values: {
        ':id' => id,
        ':sortValue' => 'questionnaire'
      }
    ).first
  end

  def initialize(**attrs)
    super(attrs)
    self.status = 'active' if status.nil? || status.empty?
  end

  def sort_key
    'questionnaire'
  end

  def attributes
    {
      code: code,
      extension: extension,
      id: primary_key,
      item: item,
      meta: meta,
      name: name,
      resourceType: resource_type,
      status: status,
      subjectType: subjectType,
      title: title,
      description: description
    }.reject { |k, v| is_blank?(v) }
  end

  private

  ##
  # Make sure display orders are set for items.
  #
  # This only does something if display order is not set by the serializer,
  # which is only the case with northwestern right now.
  def set_display_orders
    return if items.nil?

    items.each_with_index do |it, idx|
      if it.displayOrder.nil?
        it.displayOrder = idx + 1
      end
    end
  end
end
