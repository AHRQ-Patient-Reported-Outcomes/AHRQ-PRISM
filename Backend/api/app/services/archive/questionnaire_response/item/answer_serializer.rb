module Archive::QuestionnaireResponse
  module Item
    ##
    # serialize questionnaire response item answers for archiving.
    class AnswerSerializer
      def self.to_fhir(answer)
        if answer.valueCoding
          { valueCoding: answer.valueCoding }
        elsif answer.valueString
          { valueString: answer.valueString }
        else
          {}
        end
      end
    end
  end
end
