module Archive
  module Questionnaire
    ##
    # Serializes questionnaire items
    class ItemSerializer
      ##
      # For sub-objects, `fhir_models` just wants a hash.
      def self.to_fhir(item)
        options = item.answerOptions&.map do |ao|
          Questionnaire::Item::OptionSerializer.to_fhir(ao)
        end

        sub_items = item.items&.map { |it| to_fhir(it) }

        {
          code: item.code,
          extension: item.extension,
          id: item.id,
          item: sub_items,
          linkId: item.linkId,
          option: options,
          text: item.text,
          type: item.type
        }
      end
    end
  end
end
