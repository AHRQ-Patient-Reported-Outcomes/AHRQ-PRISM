# frozen_string_literal: true

require 'json'
require_relative '../../../../models/questionnaire_response'
require_relative '../../../../models/questionnaire'
require_relative '../../../../extensions/display_order'

module PromisAPI::FhirSDC
  module Serializers
    class QuestionnaireResponseSerializer
      def self.from_json(json)
        raw = JSON.parse(json)
        from_h(raw)
      end

      def self.from_h(hash)
        Models::QuestionnaireResponse.new(
          authored: hash['authored'],
          contained: hash['contained'],
          extension: hash['extension'],
          item: hash['item'],
          meta: hash['meta'],
          questionnaire_id: hash['contained'][0]['id'],
          sort_key: hash['id'],
          status: hash['status']
        )
      end

      def self.to_h(questionnaire_response)
        qr = questionnaire_response

        res = {
          'contained' => qr.contained,
          'id' => qr.id,
          'meta' => qr.meta,
          'resourceType' => qr.resourceType
        }

        res['authored'] = qr.authored unless qr.authored.nil?
        res['extension'] = qr.extension unless qr.extension.nil?
        res['item'] = qr.item unless qr.item.nil? || qr.item.empty?
        res['status'] = qr.status unless qr.status.nil?
        res
      end

      def self.to_json(questionnaire_response)
        to_h(questionnaire_response).to_json
      end
    end
  end
end
