# frozen_string_literal: true

require_relative '../serializers/questionnaire_response_serializer'

module PromisAPI
  module FhirSDC
    class Client
      module QuestionnaireResponse
        # This takes in FHIR and returns FHIR. It converts it to the PROMIS representation and then
        # parses the response.
        def next_question(questionnaire_response:)
          unless questionnaire_response.is_a? Models::QuestionnaireResponse
            raise ArgumentError,
              'questionnaire_response must be a Models::QuestionnaireResponse'
          end

          id = questionnaire_response.questionnaire_id.split('_').last
          body = serializer.to_json(questionnaire_response)

          _start = Time.now
          resp = post("/Questionnaire/#{id}/next-q", body)
          _end = Time.now
          STDOUT.puts("Just posting to PROMIS, #{(_end - _start) * 1000} ms")

          resp[:body].slice('contained', 'extension', 'meta', 'status')
        end

        private

        def serializer
          PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
        end

        def sanitize(params)
          params.slice('contained', 'extension', 'meta', 'item', 'status')
        end
      end
    end
  end
end
