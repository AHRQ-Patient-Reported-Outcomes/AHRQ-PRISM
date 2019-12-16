module Archive
  ##
  # Serializes QuestionnaireResponses to FHIR DSTU3 for storage in Google.
  #
  # Uses the `fhir_models` gem for serialization/validation.
  class QuestionnaireResponseSerializer
    def self.to_fhir(questionnaire_response)
      questionnaire_response.sanitize!

      items = questionnaire_response.items&.map do |it|
        QuestionnaireResponse::ItemSerializer.to_fhir(it)
      end

      FHIR::QuestionnaireResponse.new(
        authored: questionnaire_response.authored.to_date.iso8601,
        contained: [
          QuestionnaireSerializer.to_fhir(questionnaire_response.questionnaire)
        ],
        extension: questionnaire_response.extension,
        identifier: questionnaire_response.identifier,
        item: items,
        meta: Archive.clean_meta(questionnaire_response.meta),
        subject: questionnaire_response.subject,
        status: questionnaire_response.status,
        text: questionnaire_response.text
      )
    end
  end
end
