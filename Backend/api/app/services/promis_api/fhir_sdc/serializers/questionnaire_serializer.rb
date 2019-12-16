# frozen_string_literal: true

require_relative '../../../../models/questionnaire'
require_relative '../../../../extensions/display_order'

module PromisAPI::FhirSDC
  module Serializers
    class QuestionnaireSerializer
      def self.from_json(json)
        raw = JSON.parse(json)
        from_h(raw)
      end

      def self.from_h(hash)
        Models::Questionnaire.new(
          item: hash['item'],
          meta: hash['meta'],
          primary_key: hash['id'],
          serde_ns: 'PromisAPI::FhirSDC::Serializers'
        )
      end
    end
  end
end
