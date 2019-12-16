module Extensions
  module DisplayOrder
    URL = 'http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder'.freeze

    def displayOrder
      order = (extension || []).find { |e| e['url'] == URL }

      return nil if order.nil? || !order.has_key?('valueInteger')

      order['valueInteger'].to_i
    end

    def displayOrder=(order)
      if displayOrder
        self.extension.find { |e| e['url'] == URL }['valueInteger'] = order
      elsif self.extension
        self.extension << {'url' => URL, 'valueInteger' => order}
      else
        self.extension = [{'url' => URL, 'valueInteger' => order}]
      end

      self
    end
  end
end
