module Archive
  module QuestionnaireResponse
    ##
    # Serializers questionnaire response items for archiving.
    class ItemSerializer
      ##
      # For sub-objects, just return a hash.
      def self.to_fhir(item)
        if item.answers
          answers = item.answers.map do |answer|
            QuestionnaireResponse::Item::AnswerSerializer.to_fhir(answer)
          end
        else
          answers = nil
        end

        {
          answer: answers,
          linkId: item.linkId,
          text: item.text
        }
      end
    end
  end
end
