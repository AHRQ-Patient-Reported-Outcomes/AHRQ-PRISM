# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Models::QuestionnaireResponse::Item::Answer do
  describe 'new' do
    it 'initializes with full value coding' do
      ans = described_class.new(
        'valueString' => 'Somewhat',
        'valueCoding' => {
          'system' => 'http://hl7.org',
          'code' => 'LA3949-8',
          'display' => 'Somewhat'
        }
      )

      expect(ans.valueString).to eq 'Somewhat'
      expect(ans.valueCoding).to eq(
        'system' => 'http://hl7.org',
        'code' => 'LA3949-8',
        'display' => 'Somewhat'
      )
    end
  end
end
