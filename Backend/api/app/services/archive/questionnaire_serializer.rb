module Archive
  ##
  # Serializes Questionnaires to FHIR DSTU3 for storage in Google.
  #
  # Uses the `fhir_models` gem for serialization/validation.
  class QuestionnaireSerializer
    def self.to_fhir(questionnaire)
      FHIR::Questionnaire.new(
        code: questionnaire.code,
        extension: questionnaire.extension,
        item: questionnaire.items.map { |it| Questionnaire::ItemSerializer.to_fhir(it) },
        meta: Archive.clean_meta(questionnaire.meta),
        name: questionnaire.name,
        status: questionnaire.status,
        subjectType: questionnaire.subjectType,
        title: questionnaire.title
      )
    end
  end
end
