require 'spec_helper'

RSpec.describe PromisAPI::FhirSDC::Client do
  let(:client) { PromisAPI::FhirSDC::Client.new }

  describe 'next_question' do
    it 'rejects params that are not Models::QuestionnaireResponse' do
      expect { client.next_question questionnaire_response: nil }.to \
        raise_error(ArgumentError)

      expect do
        client.next_question questionnaire_response: Models::Questionnaire.new
      end.to raise_error(ArgumentError)
    end

    it 'goes through a questionnaire', :vcr do
      raw = file_fixture('fhir_sdc/client/qr_init_minimal.json')
      qr = PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
        .from_json(raw.read)
      qr.primary_key = current_user.id
      qr.sort_key = 'questResp-2dadee5a-61dd-45a7-8cf3-8da61661c0be'
      qr.save(force: true)

      expect(qr.containeds[0].items).to be_nil

      changes = client.next_question(questionnaire_response: qr)
      qr.update(changes)
      next_question = qr.unanswered_question

      expect(next_question.linkId).to eq 'DEE2D9CA-0094-492A-AA25-D4D53D426976'
      expect(next_question.type).to eq 'group'
      expect(next_question.items.size).to eq 2

      expect(qr.containeds[0].items.size).to eq 1

      qr.add_item(
        'extension' => [
          {
            'url' => 'http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder',
            'valueInteger' => '1'
          }
        ],
        'linkId' => 'DEE2D9CA-0094-492A-AA25-D4D53D426976',
        'answer' => [
          {
            'valueString' => 'Always',
            'valueCoding' => {
              'system' => 'http://loinc.org',
              'code' => 'LA9933-8',
              'display' => 'Always'
            }
          }
        ]
      )

      qr.update(client.next_question(questionnaire_response: qr))
      next_question = qr.unanswered_question

      expect(qr.status).to eq 'in-progress'
      expect(qr.containeds[0].items.size).to eq 2

      expect(next_question.linkId).to eq 'F1BBB664-7C68-49EC-AB50-767CDFD947BA'
      expect(next_question.type).to eq 'group'
      expect(next_question.items.size).to eq 2
    end

    it 'handles the end of a questionnaire', :vcr do
      raw = file_fixture('fhir_sdc/client/qr_finish.json')
      qr = PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
        .from_json(raw.read)
      qr.primary_key = current_user.id
      qr.sort_key = 'questResp-4efa0c07-0f83-41e5-bf77-79aee58ca8af'
      qr.save(force: true)

      # Ensure that we're actually changing values
      expect(qr.status).to eq 'in-progress'
      expect(qr.questionnaire.items.size).to eq 10
      expect(qr.theta).to eq nil
      expect(qr.std_error).to eq nil

      qr.update(client.next_question(questionnaire_response: qr))
      next_question = qr.unanswered_question
      expect(next_question).to be_nil

      expect(qr.status).to eq 'completed'
      expect(qr.containeds[0].items.size).to eq 10
      expect(qr.items.size).to eq 10
      expect(qr.theta).to be_within(0.01).of(3.4)
      expect(qr.t_score).to be_within(0.01).of(84)
      expect(qr.std_error).to be_within(0.01).of(0.3)
    end
  end
end
