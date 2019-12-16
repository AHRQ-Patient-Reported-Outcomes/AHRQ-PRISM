##
# Questionnaire answer option representation.
class Models::Questionnaire::Item::AnswerOption
  include Models::ModelBase
  include Extensions::DisplayOrder

  # persistent attributes
  list_attr :extension
  string_attr :id
  list_attr :modifierExtension
  string_attr :text
  map_attr :valueCoding

  alias_method :value, :text
  alias_method :value=, :text=

  # Do not want to persist
  def self.save; end

  def initialize(**args)
    super(args)

    @extension ||= []
  end

  def attributes
    {
      extension: extension,
      id: id,
      modifierExtension: modifierExtension,
      text: text,
      valueCoding: valueCoding
    }.reject { |k, v| is_blank?(v) }
  end
end
