module Archive::Questionnaire
  module Item
    ##
    # Serializers questionnaire item options
    class OptionSerializer
      def self.to_fhir(answer_option)
        {
          extension: answer_option.extension,
          id: answer_option.id,
          valueCoding: answer_option.valueCoding
        }
      end
    end
  end
end
