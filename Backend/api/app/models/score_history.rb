require_relative 'model_base'

module Models
  class ScoreHistory
    include ModelBase

    class << self
      def for_patient(patient_id)
        query(
          key_conditions: {
            "primaryKey" => {
              attribute_value_list: [patient_id],
              comparison_operator: 'EQ'
            },
            "sortKey" => {
              attribute_value_list: ['scoreHist'],
              comparison_operator: 'BEGINS_WITH'
            }
          }
        )
      end
    end
  end
end
