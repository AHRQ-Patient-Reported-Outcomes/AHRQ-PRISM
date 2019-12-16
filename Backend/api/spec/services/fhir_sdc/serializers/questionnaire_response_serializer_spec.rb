require 'spec_helper'

RSpec.describe PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer do
  context 'no items' do
    it 'loads minimal JSON' do
      f = file_fixture('fhir_sdc/client/qr_init_minimal.json')
      qr = described_class.from_json(f.read)

      expect(qr.id).to eq 'test'
      expect(qr.questionnaire_id).to eq '96FE494D-F176-4EFB-A473-2AB406610626'
      expect(qr.resourceType).to eq 'QuestionnaireResponse'
      expect(qr.meta).to eq(
        'profile' => [
          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaireresponse-adapt'
        ]
      )

      expect(qr.extension).to be_nil
      expect(qr.status).to eq 'in-progress'
      expect(qr.authored).to be_nil

      expect(qr.containeds.size).to eq 1

      questionnaire = qr.containeds.first
      expect(questionnaire.primary_key).to eq \
        '96FE494D-F176-4EFB-A473-2AB406610626'
      expect(questionnaire.meta).to eq(
        'profile' => [
          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-adapt'
        ]
      )
    end

    it 'parses all fields from the JSON' do
      f = file_fixture('fhir_sdc/client/questionnaire_response_init.json')
      qr = described_class.from_json(f.read)

      expect(qr.id).to eq 'test'
      expect(qr.questionnaire_id).to eq '96FE494D-F176-4EFB-A473-2AB406610626'
      expect(qr.resourceType).to eq 'QuestionnaireResponse'
      expect(qr.meta).to eq(
        'profile' => [
          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaireresponse-adapt'
        ]
      )

      expect(qr.extension[0]).to eq(
        'url' => 'http://hl7.org/fhir/StructureDefinition/questionnaire-expirationTime',
        'valueDate' => '10/21/2015 12:13:57 PM'
      )

      expect(qr.status).to eq 'in-progress'
      expect(qr.authored).to eq DateTime.new(2018, 3, 4, 16, 22, 55.772)

      expect(qr.containeds.size).to eq 1

      questionnaire = qr.containeds.first
      expect(questionnaire.primary_key).to eq \
        '96FE494D-F176-4EFB-A473-2AB406610626'
      expect(questionnaire.meta).to eq(
        'versionId' => '1',
        'profile' => [
          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-adapt'
        ],
        'lastUpdated' => '2014-11-14T10:03:25'
      )
    end

    it 'serializes all fields to JSON for FHIR' do
      raw = file_fixture('fhir_sdc/client/qr_init_minimal.json')
      good = PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
        .from_json(raw.read)
      ser = PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
        .to_h(good)

      expect(ser.with_indifferent_access).to eq \
        JSON.parse(raw.read).with_indifferent_access
    end
  end

  context 'multiple items' do
    it 'parses all fields from the JSON' do
      f = file_fixture('fhir_sdc/client/questionnaire_response_multi.json')
      qr = described_class.from_json(f.read)

      expect(qr.questionnaire_id).to eq '96FE494D-F176-4EFB-A473-2AB406610626'
      expect(qr.resourceType).to eq 'QuestionnaireResponse'
      expect(qr.meta).to eq(
        'profile' => [
          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaireresponse-adapt'
        ]
      )

      expect(qr.extension[0]).to eq(
        'url' => 'http://hl7.org/fhir/StructureDefinition/questionnaire-expirationTime',
        'valueDate' => '2019-05-09T22:21:35'
      )

      expect(qr.status).to eq 'in-progress'
      expect(qr.authored).to eq DateTime.new(2019, 5, 6, 22, 21, 35)

      expect(qr.containeds.size).to eq 1

      questionnaire = qr.containeds.first
      expect(questionnaire.primary_key).to eq \
        '96FE494D-F176-4EFB-A473-2AB406610626'
      expect(questionnaire.meta).to eq(
        'versionId' => '1',
        'profile' => [
          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-adapt'
        ],
        'lastUpdated' => '2014-11-14T10:03:25'
      )
      expect(questionnaire.items.size).to eq 4

      first = questionnaire.items[0]
      second = questionnaire.items[1]
      third = questionnaire.items[2]
      fourth = questionnaire.items[3]

      expect(first.type).to eq 'group'
      expect(first.items[0].type).to eq 'choice'
      expect(second.type).to eq 'group'
      expect(second.items[0].type).to eq 'choice'
      expect(third.type).to eq 'group'
      expect(third.items[0].type).to eq 'choice'
      expect(fourth.type).to eq 'group'
      expect(fourth.items[0].type).to eq 'display'
      expect(fourth.items[1].type).to eq 'choice'
    end

    it 'serializes all fields to JSON for FHIR' do
      raw = file_fixture('fhir_sdc/client/qr_one_minimal.json')
      good = PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
        .from_json(raw.read)
      ser = PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
        .to_h(good)

      expect(ser.with_indifferent_access).to eq \
        JSON.parse(raw.read).with_indifferent_access
    end
  end
end
