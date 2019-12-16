require 'spec_helper'

describe PromisAPI::NorthWesternSDC::Client do
  describe 'next_question' do
    let(:client) { PromisAPI::NorthWesternSDC::Client.new }

    let(:questionnaire_id) { '154D0273-C3F6-4BCE-8885-3194D4CC4596' }
    let(:questResponse) do
      Models::QuestionnaireResponse.new(questionnaire_id: questionnaire_id)
    end

    let(:answer_1) do
      {
        linkId: 'PAININ9',
        text: 'This is a question',
        answer: [{ valueString: 'Somewhat' }]
      }
    end

    let(:answer_2) do
      {
        linkId: 'PAININ31',
        text: 'This is a question',
        answer: [{ valueString: 'Somewhat' }]
      }
    end

    let(:answer_3) do
      {
        linkId: 'PAININ36',
        text: 'This is a question',
        answer: [{ valueString: 'Somewhat' }] }
    end

    let(:answer_4) do
      {
        linkId: 'PAININ22',
        text: 'This is a question',
        answer: [{ valueString: 'Somewhat' }]
      }
    end

    it 'returns the first question', :vcr do
      questResponse.item = []
      response = client.next_question(questionnaire_response: questResponse)

      expect(response.keys.sort).to eq [:contained, :extension, :meta, :status]
      expect(response[:contained][0]['item'].size).to eq 1

      item = response[:contained][0]['item'].last
      expect(item[:linkId]).to eq 'PAININ9'
    end

    it 'answers the first question and returns the second question', :vcr do
      questResponse.item = [answer_1]
      questResponse.contained = [
        {
          'resourceType' => 'Questionnaire',
          'item' => [ { linkId: answer_1[:linkId] } ]
        }
      ]

      response = client.next_question(questionnaire_response: questResponse)
        .with_indifferent_access

      expect(response.keys.sort).to eq ['contained', 'extension', 'meta', 'status']
      expect(response[:contained][0][:item].size).to eq 2
      item = response[:contained][0][:item].last
      expect(item[:linkId]).to eq 'PAININ31'

      expect(response[:extension][0][:extension][0][:valueDecimal].to_f).to be_within(0.1).of(1.0)
      expect(response[:extension][0][:extension][1][:valueDecimal].to_f).to be_within(0.1).of(0.3)
    end

    it 'answers the second question', :vcr do
      questResponse.item = [answer_1, answer_2]
      questResponse.contained = [
        {
          'resourceType' => 'Questionnaire',
          'item' => [
            { linkId: answer_1[:linkId] },
            { linkId: answer_2[:linkId] }
          ]
        }
      ]

      response = client.next_question(questionnaire_response: questResponse)
        .with_indifferent_access

      expect(response.keys.sort).to eq ['contained', 'extension', 'meta', 'status']
      expect(response[:contained][0]['item'].size).to eq 3

      item = response[:contained][0]['item'].last
      expect(item[:linkId]).to eq 'PAININ36'

      expect(response[:extension][0]['extension'][0]['valueDecimal'].to_f).to be_within(0.01).of(1.15)
      expect(response[:extension][0]['extension'][1]['valueDecimal'].to_f).to be_within(0.1).of(0.3)
    end

    it 'answers the third question', :vcr do
      questResponse.item = [answer_1, answer_2, answer_3]
      questResponse.contained = [
        {
          'resourceType' => 'Questionnaire',
          'item' => [
            { linkId: answer_1[:linkId] },
            { linkId: answer_2[:linkId] },
            { linkId: answer_3[:linkId] }
          ]
        }
      ]

      response = client.next_question(questionnaire_response: questResponse)
        .with_indifferent_access

      expect(response.keys.sort).to eq ['contained', 'extension', 'meta', 'status']
      expect(response[:contained][0]['item'].size).to eq 4

      item = response[:contained][0]['item'].last
      expect(item[:linkId]).to eq 'PAININ22'

      expect(response[:extension][0]['extension'][0]['valueDecimal'].to_f).to be_within(0.01).of(1.17)
      expect(response[:extension][0]['extension'][1]['valueDecimal'].to_f).to be_within(0.01).of(0.17)
    end

    it 'returns final results', :vcr do
      questResponse.item = [answer_1, answer_2, answer_3, answer_4]
      questResponse.contained = [
        {
          'resourceType' => 'Questionnaire',
          'item' => [
            { linkId: answer_1[:linkId] },
            { linkId: answer_2[:linkId] },
            { linkId: answer_3[:linkId] },
            { linkId: answer_4[:linkId] }
          ]
        }
      ]

      response = client.next_question(questionnaire_response: questResponse)
        .with_indifferent_access

      expect(response.keys.sort).to eq ['contained', 'extension', 'meta', 'status']

      expect(response[:status]).to eq 'completed'
      expect(response[:extension][0]['extension'][0]['valueDecimal'].to_f).to be_within(0.01).of(1.15)
      expect(response[:extension][0]['extension'][1]['valueDecimal'].to_f).to be_within(0.01).of(0.15)
    end
  end
end
