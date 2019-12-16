##
# Questionnaire response item (e.g. an answer).
class Models::QuestionnaireResponse::Item
  include Models::ModelBase
  include Extensions::DisplayOrder

  list_attr :extension
  string_attr :linkId
  string_attr :text
  obj_list_attr :answer, class_name: Answer.to_s

  def attributes
    {
      answer: answer,
      extension: extension,
      linkId: linkId,
      text: text
    }.reject { |k, v| is_blank?(v) }
  end
end
