require_relative '../../../../models/questionnaire_response'
require_relative '../../../../models/questionnaire'
require_relative '../../../../extensions/display_order'

module PromisAPI::NorthWesternSDC
  module Serializers
    class QuestionnaireResponseSerializer
      def self.promis_next_question(questionnaire_response:)
        raise 'must be a QuestionnaireResponse' unless questionnaire_response.is_a? Models::QuestionnaireResponse

        items = questionnaire_response.items || []
        items.reduce({}) do |obj, item|
          obj[item.linkId] = item.answers.first.valueString
          obj
        end
      end

      def self.promis_to_fhir(data:)
        item = if (!data['Items'] || data['Items'].empty?)
            []
          else
            item_data = data['Items'][0]
            Models::Questionnaire::Item.new(
              build_item(item_data)
            ).serializable_hash
          end

        { item: item, scores: { theta: data['Theta'], std_error: data['StdError'] } }
      end

      private

      def self.build_item(data)
        type = item_type(data)

        # NOTE: displayOrder is ignored for Questionnaire::Item on purpose for
        # northwestern

        {
          linkId: data['ID'] || data['ElementOID'],
          type: type,
          code: {},
          text: include_description(data) ? data['Description'] : nil,
          answerOption: type == 'choice' ? build_answerOption(data) : [],
          item: (data['Elements'] && !data['Elements'].empty?) ? data['Elements'].map { |d| build_item(d) } : []
        }
      end

      def self.build_answerOption(data)
        raise 'incompatible item type. choice answer is missing options' if !data['Map']

        data['Map'].map do |d|
          order = data['Order'] || data['ElementOrder'] || data['Position']

          {
            id: d.fetch('ElementOID'),
            displayOrder: order,
            text: d.fetch('Description')
          }
        end
      end

      # Promis server returns a description for "choice" question that should not be displayed or saved b/c
      # it is nonsense for text.
        # This checks
      def self.include_description(data)
        data['Description'] && !data['Description'].match(/(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}/)
      end

      def self.item_type(data)
        if data['Map']
          return 'choice'
        elsif data['Elements'] && !data['Elements'].empty?
          return 'group'
        else
          return 'display'
        end
      end
    end
  end
end
