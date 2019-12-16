require 'spec_helper'
require_relative '../../support/display_order_examples'

describe Models::QuestionnaireResponse::Item do
  it_behaves_like 'display order'

  describe 'serialization' do
    let(:link_id) { SecureRandom.uuid }

    let(:item) do
      described_class.new(
        linkId: link_id,
        text: 'Never',
        answer: [
          {
            valueString: 'Never',
            valueCoding: {
              system: 'http://loinc.org',
              code: 'LA6270-8',
              display: 'Never'
            }
          }
        ]
      )
    end

    it 'has a linkId' do
      expect(item.linkId).to eq link_id
    end

    it 'has text' do
      expect(item.text).to eq 'Never'
    end

    it 'has an answer' do
      actual = item.answers.first
      expect(actual.valueString).to eq 'Never'
      expect(actual.valueCoding).to eq(
        system: 'http://loinc.org',
        code: 'LA6270-8',
        display: 'Never'
      )
    end

    it 'has raw answer content' do
      expect(item.answer).to eq([
        {
          valueString: 'Never',
          valueCoding: {
            system: 'http://loinc.org',
            code: 'LA6270-8',
            display: 'Never'
          }
        }
      ])
    end

    it 'updates raw content via objects' do
      item.answers[0].valueString = 'fake'
      expect(item.answer.first[:valueString]).to eq 'fake'
    end
  end
end
