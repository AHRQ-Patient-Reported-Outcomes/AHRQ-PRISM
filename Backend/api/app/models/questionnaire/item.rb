##
# A questionnaire item (e.g. a question).
class Models::Questionnaire::Item
  include Models::ModelBase
  include Extensions::DisplayOrder

  obj_list_attr :answerOption, class_name: AnswerOption.to_s
  list_attr :code
  list_attr :extension
  string_attr :id
  obj_list_attr :item, class_name: 'Models::Questionnaire::Item'
  string_attr :linkId
  string_attr :text
  string_attr :type

  validates_presence_of :linkId, :text
  validates_inclusion_of :type, in: ['group', 'display', 'choice']

  def initialize(**args)
    super(**args)

    @answerOption ||= []
    @item ||= []
    @code ||= []
    @extension ||= []
  end

  # Do not want to persist
  def self.save; end

  def attributes
    {
      answerOption: answerOption,
      code: code,
      extension: extension,
      id: id,
      item: item,
      linkId: linkId,
      text: text,
      type: type
    }.reject { |k, v| is_blank?(v) }
  end

  def all_answer_options
    if type == 'choice'
      answerOptions || []
    elsif type == 'group'
      items.map(&:all_answer_options).flatten
    else
      []
    end
  end
end
