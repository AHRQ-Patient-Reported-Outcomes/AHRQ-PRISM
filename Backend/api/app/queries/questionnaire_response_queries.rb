module Queries
  module QuestionnaireResponseQueries
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      IN_PROGRESS_INDEX = 'inProgressQuestionnaireResponses'

      def find(patient_id, quest_resp_id)
        query(
          key_condition_expression: 'primaryKey = :id AND sortKey = :sortValue',
          expression_attribute_values: {
            ':id' => patient_id,
            ':sortValue' => quest_resp_id
          }
        ).first
      end

      def for_patient(patient_id, status_filter = nil)
        query_params = {
          key_condition_expression: 'primaryKey = :id AND begins_with(sortKey, :sortValue)',
          expression_attribute_values: {
            ':id' => patient_id,
            ':sortValue' => 'questResp'
          }
        }

        if ['completed', 'in-progress'].include?(status_filter)
          query_params[:filter_expression] = '#s = :statusVal'
          query_params[:expression_attribute_names] = { '#s' => 'status' }
          query_params[:expression_attribute_values][':statusVal'] = status_filter
        end

        query(query_params).to_a
      end
    end
  end
end
