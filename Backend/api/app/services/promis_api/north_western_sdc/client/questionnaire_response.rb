# frozen_string_literal: true

require_relative '../../../../extensions/display_order'
require_relative '../serializers/questionnaire_response_serializer'

module PromisAPI
  module NorthWesternSDC
    class Client
      module QuestionnaireResponse
        # This takes in FHIR and returns FHIR. It converts it to the PROMIS representation and then
        # parses the response.
        def next_question(questionnaire_response:)
          data = serializer.promis_next_question(questionnaire_response: questionnaire_response)

          id = questionnaire_response.questionnaire_id.split('questionnaire_').last

          response = post("/StatelessParticipants/#{id}.json", data)

          item, scores = serializer.promis_to_fhir(data: response[:body]).values_at(:item, :scores)

          {
            contained: update_contained(questionnaire_response, item),
            extension: extension(scores),
            meta: [],
            status: item.is_a?(Array) && item.empty? ? 'completed' : 'in-progress'
          }
        end

        private

        def update_contained(quest_resp, item)
          idx = quest_resp.contained
            &.index { |c| c[:resourceType] == 'Questionnaire' }

          if idx
            new_contained = quest_resp.contained.dup
            return new_contained unless item && !item.empty?

            # fix display order since northwestern seems to return random
            # displayOrder fields
            displayOrder = (new_contained[idx][:item]&.size || 0) + 1
            order_idx = (item[:extension] || []).index do |ext|
              ext[:url] == Extensions::DisplayOrder::URL
            end
            if order_idx
              item[:extension][order_idx][:valueInteger] = displayOrder.to_s
            else
              item[:extension] = [{
                url: Extensions::DisplayOrder::URL,
                valueInteger: displayOrder
              }]
            end

            if new_contained[idx][:item]
              new_contained[idx][:item] << item
            else
              new_contained[idx][:item] = [item]
            end

            new_contained
          else
            [
              {
                'resourceType' => 'Questionnaire',
                'item' => [item || nil].compact
              }
            ]
          end
        end

        def extension(scores)
          [{
            'url' => 'http://hl7.org/fhir/StructureDefinition/questionnaire-scores',
            'extension' => [{
              'url' => 'http://hl7.org/fhir/StructureDefinition/questionnaire-scores/theta',
              'valueDecimal' => scores[:theta]
            }, {
              'url' => 'http://hl7.org/fhir/StructureDefinition/questionnaire-scores/standarderror',
              'valueDecimal' => scores[:std_error]
            }]
          }]
        end

        def serializer
          PromisAPI::NorthWesternSDC::Serializers::QuestionnaireResponseSerializer
        end
      end
    end
  end
end
