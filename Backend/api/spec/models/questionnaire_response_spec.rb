require 'spec_helper'

describe Models::QuestionnaireResponse do
  let(:questResponse) do
    Models::QuestionnaireResponse.new(questionnaire_id: 'questionnaire_id',
                                      status: 'in-progress',
                                      primary_key: '1',
                                      item: [])
  end

  describe 'add_item' do
    let(:item_1) do
      {
        linkId: 'PAININ9',
        text: 'This is a question',
        answer: [ { valueString: 'Somewhat' } ]
      }
    end

    let(:item_1_dup) do
      {
        linkId: 'PAININ9',
        text: 'This is a question',
        answer: [ { valueString: 'Never' } ]
      }
    end

    let(:item_2) do
      {
        linkId: 'PAININ36',
        text: 'This is a question',
        answer: [ { valueString: 'Somewhat' } ]
      }
    end

    it 'adds an item' do
      questResponse.add_item(item_1)

      expect(questResponse.items.size).to eq 1
    end

    it 'adds multiple items' do
      questResponse.add_item(item_1)
      expect(questResponse.items.size).to eq 1

      questResponse.add_item(item_2)
      expect(questResponse.items.size).to eq 2
    end

    it 'updates items with duplicate linkIds' do
      questResponse.add_item(item_1)
      expect(questResponse.items.size).to eq 1

      questResponse.add_item(item_1_dup)
      expect(questResponse.items.size).to eq 1
      item = questResponse.items.first
      expect(item.linkId).to eq 'PAININ9'
      expect(item.answers.first.valueString).to eq 'Never'
    end
  end

  it 'saves and reloads' do
    raw = file_fixture('fhir_sdc/client/qr_finish.json')
    qr = PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
      .from_json(raw.read)
    qr.primary_key = current_user.id
    qr.save(force: true)

    expect(qr.items.size).to eq 10

    qr.add_item(linkId: 'PAININ9', text: 'this is a question',
                answer: [ { text: 'Somewhat' } ])
    qr.save!(force: true)
    expect(qr.items.size).to eq 11
    qr = qr.reload
    expect(qr.item.size).to eq 11
  end
end
