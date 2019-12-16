##
# Questionnaire response item answer field.
class Models::QuestionnaireResponse::Item::Answer
  include Models::ModelBase

  map_attr :valueCoding
  string_attr :valueString

  alias_method :value, :valueString
  alias_method :value=, :valueString=

  # ignore 'text' but allow writing
  attr_writer :text

  ##
  # FHIR demands only one value[x]
  def attributes
    {
      valueCoding: valueCoding,
      valueString: valueString
    }
  end
end
