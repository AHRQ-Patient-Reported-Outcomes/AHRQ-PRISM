# frozen_string_literal: true

require_relative 'model_base'
require_relative '../queries/questionnaire_response_queries'
require_relative '../extensions/display_order'

# https://github.com/fhir-crucible/fhir_models/blob/1ebe780196c64f0fa46bad47609493c73a63b778/lib/fhir_models/fhir/resources/QuestionnaireResponse.rb
class Models::QuestionnaireResponse
  include Models::ModelBase
  include Queries::QuestionnaireResponseQueries

  ADAPTIVE_META = 'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaireresponse-adapt'

  alias_method :id, :sort_key
  alias_method :id=, :sort_key=

  # persistent attributes
  datetime_attr :authored
  obj_list_attr :contained
  list_attr :extension
  map_attr :identifier
  obj_list_attr :item, class_name: 'Models::QuestionnaireResponse::Item'
  map_attr :meta
  string_attr :patient_id, database_attribute_name: 'GSI_1_PK'
  string_attr :questionnaire_id, database_attribute_name: 'GSI_1_SK'
  map_attr :result_modal_data
  string_attr :status
  map_attr :subject
  string_attr :text

  # persistent Non FHIR attrs
  string_attr :is_in_progress, database_attribute_name: 'GSI_2_PK'
  float_attr :theta
  float_attr :std_error
  map_attr :population_comparison

  validates_presence_of :questionnaire_id, :patient_id
  validates_inclusion_of :status, in: ['in-progress', 'completed']
  validates_presence_of :theta, :std_error, if: :completed?

  before_validation :set_status
  before_validation :set_contained_id
  before_validation :set_patient_id
  before_validation :set_sort_key
  before_validation :set_scores, if: :completed?
  before_validation :validate_contained

  def reload
    self.class.find(primary_key, sort_key)
  end

  ##
  # Add or update an item from raw data.
  #
  # If an item with the same link ID already exists, it's updated.
  def add_item(item_data)
    existing = items&.index do |it|
      it.linkId == item_data.with_indifferent_access[:linkId]
    end

    if existing
      items[existing] = Item.new(item_data)
    elsif items
      self.items << Item.new(item_data)
    else
      self.items = [Item.new(item_data)]
    end
  end

  ##
  # Delete an item.
  def del_item(linkId)
    items&.delete_if { |it| it.linkId == linkId }
  end

  def attributes
    {
      id: sort_key,
      resourceType: resource_type,
      questionnaire_id: questionnaire_id,
      patient_id: patient_id,
      authored: authored,
      status: status,
      theta: theta,
      std_error: std_error,
      contained: contained,
      item: item,
      result_modal_data: result_modal_data,
      population_comparison: population_comparison,
      extension: extension,
      subject: subject
    }.reject { |k, v| is_blank?(v) }
  end

  def actual_questionnaire_id
    questionnaire_id.sub(/^questionnaire_/, '')
  end

  alias_method :old_pop_comp, :population_comparison
  def population_comparison
    make_obj = Proc.new do |thing|
      if thing
        {
          description: thing['description'],
          value: thing['value']&.to_i
        }
      end
    end

    if old_pop_comp
      {
        age: make_obj.call(old_pop_comp['age']),
        gender: make_obj.call(old_pop_comp['gender']),
        total: old_pop_comp['total']&.to_i
      }
    end
  end

  def completed?
    status == 'completed'
  end

  def in_progress?
    status == 'in-progress'
  end

  ##
  # Remove questions after the given index based on display order, and
  # remove answers at and after the given index.
  #
  # This function is used to "reset" the QuestionnaireResponse to an earlier
  # question.
  def remove_after_index(idx)
    answers_to_remove = items.select { |i| i.displayOrder >= idx }
    answers_to_remove.each { |a| del_item(a.linkId) }

    questions_to_remove = questionnaire.items
      .select { |i| i.displayOrder > idx }
    questions_to_remove.each do |q|
      questionnaire.items.delete_if { |it| it.linkId == q.linkId }
    end
  end

  def unanswered_question
    return nil if questionnaire.nil? || completed? || questionnaire.item.nil?

    answered = items&.map(&:linkId) || []
    questionnaire.items.reject { |it| answered.include?(it.linkId) }.first
  end

  def t_score
    (theta * 10.0) + 50.0
  end

  def questionnaire
    (containeds || []).find { |r| r.is_a? Models::Questionnaire }
  end

  def add_answer(linkId, values)
    # find the question being answered
    q = questionnaire.items.find { |q| q.linkId == linkId }
    return if q.nil?

    # get the answers chosen by the user out of the available options
    chosen = q.all_answer_options.select do |ao|
      values.include?(ao.text)
    end

    raise "#{values.inspect} is not a valid answer" if chosen.empty?

    answers = chosen.map do |ao|
      {
        'text' => ao.text,
        'valueString' => ao.text,
        'valueCoding' => ao.valueCoding
      }
    end

    add_item(
      'extension' => [
        {
          'url' => 'http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder',
          'valueInteger' => q.displayOrder.to_s
        }
      ],
      'linkId' => linkId,
      'answer' => answers
    )
  end

  def reset
    self.items = nil
    self.questionnaire.items = nil if self.questionnaire
    self.status = 'in-progress'

    # clear scores
    self.extension.reject! { |ext| ext['url'] =~ %r{/questionnaire-scores$} }
    self.theta = nil
    self.std_error = nil

    self.authored = nil
  end

  private

  def validate_contained
    return if containeds.nil?

    containeds.each do |cr|
      next if cr.valid?
      cr.errors.each do |attr, msg|
        errors.add("contained/#{cr.class.to_s}/#{attr}", msg)
      end
    end
  end

  def set_status
    self.status = 'in-progress' if status.nil? || status.empty?
  end

  def set_contained_id
    return if questionnaire.nil?
    questionnaire.id = questionnaire_id
  end

  def set_patient_id
    self.patient_id = primary_key
  end

  def set_sort_key
    if sort_key.nil? || sort_key.empty? || !(sort_key =~ /^questResp-/)
      self.sort_key = "questResp-#{SecureRandom.uuid}"
    end
  end

  def set_scores
    extension.each do |ext|
      ext_indif = ext.with_indifferent_access
      next unless ext_indif['url'] =~ %r{/questionnaire-scores$}
      ext_indif['extension'].each do |deep_ext|
        deep_ext_indif = deep_ext.with_indifferent_access
        case deep_ext_indif['url']
        when %r{/questionnaire-scores/theta$}
          self.theta = deep_ext['valueDecimal']
        when %r{/questionnaire-scores/standarderror$}
          self.std_error = deep_ext['valueDecimal']
        end
      end
    end
  end
end
