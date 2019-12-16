require 'spec_helper'

# shim in a way to reset the client to nil
module PromisAPI
  class << self
    def reset!
      @client = nil
    end
  end
end

describe QuestionnaireResponsesController do
  after :each do
    Models::QuestionnaireResponse.scan.each(&:delete!)
  end

  let(:empty) do
    qr = Models::QuestionnaireResponse.new(
      contained: [{ "resourceType" => "Questionnaire", "id" => "154D0273-C3F6-4BCE-8885-3194D4CC4596", "meta" => { "profile": [ "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-adapt" ] }, "subjectType": ["Patient"] }],
      meta: { 'profile' => [ 'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaireresponse-adapt' ] },
      primary_key: current_user.id,
      sort_key: 'questResp-a39bf9b3-b42d-4913-90a0-dcd23a782695',
      questionnaire_id: '154D0273-C3F6-4BCE-8885-3194D4CC4596',
      status: 'in-progress'
    )
    qr.save! force: true
    qr
  end

  let(:full) do
    qr = Models::QuestionnaireResponse.new(
      contained: [{"resourceType"=>"Questionnaire", "item"=>[{"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"1"}], "displayOrder"=>0.1e1, "linkId"=>"PAININ9", "text"=>nil, "code"=>{}, "type"=>"group", "answerOption"=>[], "item"=>[{"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"1"}], "displayOrder"=>0.1e1, "linkId"=>"8AB8BA58-3BB0-40B6-B656-C24F1169069B", "text"=>"In the past 7 days", "code"=>{}, "type"=>"display", "answerOption"=>[], "item"=>[]}, {"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"2"}], "displayOrder"=>0.2e1, "linkId"=>"5B10732E-3A51-438C-A437-B07E2CFBE71A", "text"=>"How much did pain interfere with your day to day activities?", "code"=>{}, "type"=>"display", "answerOption"=>[], "item"=>[]}, {"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"3"}], "displayOrder"=>0.3e1, "linkId"=>"B8630087-5995-4B62-8BE1-55BDEA27A80A", "text"=>nil, "code"=>{}, "type"=>"choice", "answerOption"=>[{"id"=>"949D2A4E-3A2B-4CD6-BE45-33C56EA76813", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"1"}], "value"=>"1", "displayOrder"=>0.1e1, "text"=>"Not at all"}, {"id"=>"7C45E84C-87A5-410B-BF19-29D75531EFF4", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"2"}], "value"=>"2", "displayOrder"=>0.2e1, "text"=>"A little bit"}, {"id"=>"441EE176-E592-4B32-B5FE-83B738EB10BA", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"3"}], "value"=>"3", "displayOrder"=>0.3e1, "text"=>"Somewhat"}, {"id"=>"29BD9E0E-298C-4A51-99C3-48B9D4D25B07", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"4"}], "value"=>"4", "displayOrder"=>0.4e1, "text"=>"Quite a bit"}, {"id"=>"74DC8842-078A-4DC6-B9C9-1656A8775657", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"5"}], "value"=>"5", "displayOrder"=>0.5e1, "text"=>"Very much"}], "item"=>[]}]}]}],
      meta: { 'profile' => [ 'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaireresponse-adapt' ] },
      population_comparison: Population.get_percentiles(form_id: '36f00430-cc4c-4977-ae8a-0787b3c53ab8', t_score: 50),
      primary_key: current_user.id,
      sort_key: 'questResp-851666e0-8e81-4cee-8725-efe67eee1f96',
      questionnaire_id: '154D0273-C3F6-4BCE-8885-3194D4CC4596',
      status: 'in-progress'
    )
    qr.save! force: true
    qr
  end

  let(:almost_complete) do
    raw = file_fixture('fhir_sdc/client/qr_finish.json')
    qr = PromisAPI::FhirSDC::Serializers::QuestionnaireResponseSerializer
      .from_json(raw.read)
    qr.id = '' # blank it so a random one is generated
    qr.sort_key = 'questResp-751666e0-8e81-4cee-8725-efe67eee1f96'
    qr.subject = {
      reference: 'Patient/524d6fcc-9cec-44f7-82b7-7b0253d13a46'
    }
    qr.primary_key = current_user.id
    qr.save! force: true
    qr
  end

  describe 'GET :id' do
    it 'returns the whole QuestionnaireResponse' do
      get "QuestionnaireResponses/#{full.id}"

      expect(last_response.status).to eq 200

      body = JSON.parse(last_response.body, symbolize_names: true)
      raw = body[:questionnaireResponses]

      expect(raw[:contained][0][:item].size).to eq 1
      expect(raw[:population_comparison]).to eq(
        age: nil,
        gender: nil,
        total: 52
      )
    end
  end

  describe 'GET /' do
    before do
      full
      almost_complete.extension << { "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-scores", "extension": [ { "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-scores/theta", "valueDecimal": 3.4 }, { "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-scores/standarderror", "valueDecimal": 0.3 } ] }
      almost_complete.status = 'completed'
      almost_complete.save!

      expect(almost_complete.primary_key).to eq full.primary_key
      expect(almost_complete.sort_key).not_to eq full.sort_key
    end

    it 'returns in progress questionnaires' do
      get 'QuestionnaireResponses?status=in-progress'

      expect(last_response.status).to eq 200

      body = JSON.parse(last_response.body, symbolize_names: true)
      raw = body[:questionnaireResponses]

      expect(raw.size).to eq 1
      expect(raw[0][:id]).to eq full.sort_key
    end

    it 'returns completed questionnaires' do
      get 'QuestionnaireResponses?status=completed'

      expect(last_response.status).to eq 200

      body = JSON.parse(last_response.body, symbolize_names: true)
      raw = body[:questionnaireResponses]

      expect(raw.size).to eq 1
      expect(raw[0][:id]).to eq almost_complete.sort_key
    end
  end

  describe 'GET :id/reset' do
    before(:all) do
      PromisAPI.reset!
      @prev_api_type = $config['promis_api_type']
      $config['promis_api_type'] = 'FhirSDC'
    end

    after(:all) do
      $config['promis_api_type'] = @prev_api_type
      PromisAPI.reset!
    end

    context 'with async archive on' do
      before do
        @orig = ENV['ASYNC_ARCHIVE']
        ENV['ASYNC_ARCHIVE'] = 'true'
      end

      after { ENV['ASYNC_ARCHIVE'] = @orig }

      it 'resets the questionnaire as if it had not been started', :vcr do
        client = Aws::Lambda::Client.new(region: 'us-east-1')
        expect(Aws::Lambda::Client).to receive(:new).and_return(client)
        expect(client).to receive(:invoke)

        allow(DateTime).to receive(:now) { DateTime.new(2019, 6, 26) }

        answer = {
          item: {
            linkId: '12FC21DA-6160-4ADF-9528-0A75A40E6FFA',
            answer: [{ value: 'Always'}]
          }
        }

        bday = Date.new(Date.today.year - 50, Date.today.month, Date.today.day)
        patient = Models::Patient.new(primary_key: current_user.id,
                                      _fhir_access_data: {
                                        access_token: ENV['TEST_HUB_AUTH_TOKEN']
                                      },
                                      name: [{ given: 'John', family: 'Doe' }],
                                      organization_id: SecureRandom.uuid,
                                      gender: 'male',
                                      birthDate: bday)
        patient.save! force: true

        # Complete the questionnaire
        post "QuestionnaireResponses/#{almost_complete.id}/next-q", answer.to_json

        qr = Db.find_questionnaire_response(current_user.id, almost_complete.id)

        expect(qr.items).not_to be_empty
        expect(qr.status).to eq 'completed'
        expect(qr.authored).to eq Date.new(2019, 6, 26)
        expect(qr.theta).to be_within(0.01).of(3.4)
        expect(qr.std_error).to be_within(0.01).of(0.3)
        expect(qr.questionnaire).not_to be_nil
        expect(qr.questionnaire.items).not_to be_empty

        # reset the questionnaire
        get "QuestionnaireResponses/#{almost_complete.id}/reset"

        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to eq('success' => true)

        qr = Db.find_questionnaire_response(current_user.id, almost_complete.id)

        expect(qr.items).to be_nil
        expect(qr.status).to eq 'in-progress'
        expect(qr.authored).to be_nil
        expect(qr.theta).to be_nil
        expect(qr.std_error).to be_nil
        expect(qr.questionnaire).not_to be_nil
        expect(qr.questionnaire.items).to be_nil
      end
    end

    context 'with async archive OFF' do
      before do
        @orig = ENV['ASYNC_ARCHIVE']
        ENV['ASYNC_ARCHIVE'] = nil
      end

      after { ENV['ASYNC_ARCHIVE'] = @orig }

      it 'resets the questionnaire as if it had not been started', :vcr do
        client = Archive::Client.new(auth_token: 'abc_123')
        expect(Archive::Client).to receive(:new).and_return(client)
        expect(client).to receive(:archive)

        allow(DateTime).to receive(:now) { DateTime.new(2019, 6, 26) }

        answer = {
          item: {
            linkId: '12FC21DA-6160-4ADF-9528-0A75A40E6FFA',
            answer: [{ value: 'Always'}]
          }
        }

        bday = Date.new(Date.today.year - 50, Date.today.month, Date.today.day)
        patient = Models::Patient.new(primary_key: current_user.id,
                                      _fhir_access_data: {
                                        access_token: ENV['TEST_HUB_AUTH_TOKEN']
                                      },
                                      name: [{ given: 'John', family: 'Doe' }],
                                      organization_id: SecureRandom.uuid,
                                      gender: 'male',
                                      birthDate: bday)
        patient.save! force: true

        # Complete the questionnaire
        post "QuestionnaireResponses/#{almost_complete.id}/next-q", answer.to_json

        qr = Db.find_questionnaire_response(current_user.id, almost_complete.id)

        expect(qr.items).not_to be_empty
        expect(qr.status).to eq 'completed'
        expect(qr.authored).to eq Date.new(2019, 6, 26)
        expect(qr.theta).to be_within(0.01).of(3.4)
        expect(qr.std_error).to be_within(0.01).of(0.3)
        expect(qr.questionnaire).not_to be_nil
        expect(qr.questionnaire.items).not_to be_empty

        # reset the questionnaire
        get "QuestionnaireResponses/#{almost_complete.id}/reset"

        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to eq('success' => true)

        qr = Db.find_questionnaire_response(current_user.id, almost_complete.id)

        expect(qr.items).to be_nil
        expect(qr.status).to eq 'in-progress'
        expect(qr.authored).to be_nil
        expect(qr.theta).to be_nil
        expect(qr.std_error).to be_nil
        expect(qr.questionnaire).not_to be_nil
        expect(qr.questionnaire.items).to be_nil
      end
    end
  end

  describe 'POST /:id/archive' do
    let(:client) { double }
    let(:access_token) { 'abc_foo_test_123' }

    it 'finds and archives the questionnaire' do
      patient = Models::Patient.new(
        primary_key: current_user.id,
        _fhir_access_data: { access_token: access_token },
        name: [{ given: 'John', family: 'Doe' }],
        organization_id: SecureRandom.uuid,
        gender: 'male',
        birthDate: Date.new(Date.today.year - 50, Date.today.month, Date.today.day)
      )
      patient.save! force: true

      expect(Db).to(receive(:find_questionnaire_response).with(current_user.id, full.id).and_call_original)
      expect(Models::Patient).to(receive(:find).with(current_user.id).and_call_original)

      expect(Archive::Client).to receive(:new).with(auth_token: access_token).and_return(client)
      expect(client).to receive(:archive)

      post "QuestionnaireResponses/#{full.id}/archive"

      expect(last_response.status).to eq 200
    end
  end

  describe 'POST /:id/archive' do
    let(:client) { double }
    let(:access_token) { 'abc_foo_test_123' }

    it 'finds and archives the questionnaire' do
      patient = Models::Patient.new(
        primary_key: current_user.id,
        _fhir_access_data: { access_token: access_token },
        name: [{ given: 'John', family: 'Doe' }],
        organization_id: SecureRandom.uuid,
        gender: 'male',
        birthDate: Date.new(Date.today.year - 50, Date.today.month, Date.today.day)
      )
      patient.save! force: true

      expect(Db).to(receive(:find_questionnaire_response).with(current_user.id, full.id).and_call_original)
      expect(Models::Patient).to(receive(:find).with(current_user.id).and_call_original)

      expect(Archive::Client).to receive(:new).with(auth_token: access_token).and_return(client)
      expect(client).to receive(:archive)

      post "QuestionnaireResponses/#{full.id}/archive"

      expect(last_response.status).to eq 200
    end
  end

  context 'NorthwesternSDC' do
    before(:all) do
      PromisAPI.reset!
      @prev_api_type = $config['promis_api_type']
      $config['promis_api_type'] = 'NorthWesternSDC'
    end

    after(:all) do
      $config['promis_api_type'] = @prev_api_type
      PromisAPI.reset!
    end

    describe 'GET /next-q' do
      it 'initializes a questionnaire if needed', :vcr do
        get "QuestionnaireResponses/#{empty.id}/next-q"
        expect(last_response.status).to eq 200

        body = JSON.parse(last_response.body)
        q = body['questionnaireItem']
        expect(q['linkId']).to eq 'PAININ9'

        qr = Db.find_questionnaire_response(current_user.id, empty.id)

        expect(qr.questionnaire).not_to be_nil
        expect(qr.questionnaire.items).not_to be_nil
        expect(qr.questionnaire.items[0].linkId).to eq 'PAININ9'
      end

      it 'returns the latest question if there is an unanswered question' do
        empty.contained = [
          {
            'resourceType' => 'Questionnaire',
            'id' => '154D0273-C3F6-4BCE-8885-3194D4CC4596',
            'item' => [
              {
                'linkId' => 'PAININ9',
                'type' => 'group',
                'answerOption' => []
              }
            ]
          }
        ]
        empty.save! force: true

        get "QuestionnaireResponses/#{empty.id}/next-q"

        body = JSON.parse(last_response.body)
        q = body['questionnaireItem']
        expect(q['linkId']).to eq 'PAININ9'
      end
    end

    describe 'POST /next-q' do
      it "can't answer if there's no question" do
        answer = {
          item: {
            linkId: 'PAININ9',
            answer: [{ value: 'Somewhat' }]
          }
        }

        post "QuestionnaireResponses/#{empty.id}/next-q", answer.to_json

        expect(last_response.status).to eq 400

        qr = Db.find_questionnaire_response(current_user.id, empty.id)
        expect(qr.item).to be_nil
      end

      it 'answers a question and returns the next question', :vcr do
        answer = {
          item: {
            linkId: 'PAININ9',
            answer: [{ value: 'Somewhat' }]
          }
        }

        post "QuestionnaireResponses/#{full.id}/next-q",
          answer.to_json

        expect(last_response.status).to eq 200

        body = JSON.parse(last_response.body)
        item = body['questionnaireItem']

        expect(item['linkId']).to eq 'PAININ31'

        qr = Db.find_questionnaire_response(current_user.id, full.id)
        expect(qr.item.size).to eq 1
        expect(qr.item[0]['linkId']).to eq 'PAININ9'
        expect(qr.contained[0]['item'][1]['linkId']).to eq 'PAININ31'
      end

      it 'answers a bunch of questions', :vcr do
        answer = { item:{ linkId: 'PAININ9', answer: [{ value: 'Somewhat' }]}}
        post "QuestionnaireResponses/#{full.id}/next-q", answer.to_json
        expect(last_response.status).to eq 200
        body = JSON.parse(last_response.body)
        item = body['questionnaireItem']
        expect(item['linkId']).to eq 'PAININ31'
        expect(item['extension'][0]['valueInteger']).to eq 2 # displayOrder
        qr = Db.find_questionnaire_response(current_user.id, full.id)
        expect(qr.item.size).to eq 1
        expect(qr.items.last.displayOrder).to eq 1

        answer = { item:{ linkId: 'PAININ31', answer: [{ value: 'Somewhat' }]}}
        post "QuestionnaireResponses/#{full.id}/next-q", answer.to_json
        expect(last_response.status).to eq 200
        body = JSON.parse(last_response.body)
        item = body['questionnaireItem']
        expect(item['linkId']).to eq 'PAININ36'
        expect(item['extension'][0]['valueInteger']).to eq 3 # displayOrder
        qr = Db.find_questionnaire_response(current_user.id, full.id)
        expect(qr.item.size).to eq 2
        expect(qr.items.last.displayOrder).to eq 2

        answer = { item:{ linkId: 'PAININ36', answer: [{ value: 'Somewhat' }]}}
        post "QuestionnaireResponses/#{full.id}/next-q", answer.to_json
        expect(last_response.status).to eq 200
        body = JSON.parse(last_response.body)
        item = body['questionnaireItem']
        expect(item['linkId']).to eq 'PAININ22'
        expect(item['extension'][0]['valueInteger']).to eq 4 # displayOrder
        qr = Db.find_questionnaire_response(current_user.id, full.id)
        expect(qr.item.size).to eq 3
        expect(qr.items.last.displayOrder).to eq 3
      end

      it 'handles answers for previous questions', :vcr do
        qr = Models::QuestionnaireResponse.new(
          contained: [{"resourceType"=>"Questionnaire", "item"=>[{"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.6e1"}], "displayOrder"=>0.6e1, "linkId"=>"PAININ9", "text"=>nil, "code"=>{}, "type"=>"group", "answerOption"=>[], "item"=>[{"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.1e1"}], "displayOrder"=>0.1e1, "linkId"=>"8AB8BA58-3BB0-40B6-B656-C24F1169069B", "text"=>"In the past 7 days", "code"=>{}, "type"=>"display", "answerOption"=>[], "item"=>[]}, {"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.2e1"}], "displayOrder"=>0.2e1, "linkId"=>"5B10732E-3A51-438C-A437-B07E2CFBE71A", "text"=>"How much did pain interfere with your day to day activities?", "code"=>{}, "type"=>"display", "answerOption"=>[], "item"=>[]}, {"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.3e1"}], "displayOrder"=>0.3e1, "linkId"=>"B8630087-5995-4B62-8BE1-55BDEA27A80A", "text"=>nil, "code"=>{}, "type"=>"choice", "answerOption"=>[{"id"=>"949D2A4E-3A2B-4CD6-BE45-33C56EA76813", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.1e1"}], "value"=>"1", "displayOrder"=>0.1e1, "text"=>"Not at all"}, {"id"=>"7C45E84C-87A5-410B-BF19-29D75531EFF4", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.2e1"}], "value"=>"2", "displayOrder"=>0.2e1, "text"=>"A little bit"}, {"id"=>"441EE176-E592-4B32-B5FE-83B738EB10BA", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.3e1"}], "value"=>"3", "displayOrder"=>0.3e1, "text"=>"Somewhat"}, {"id"=>"29BD9E0E-298C-4A51-99C3-48B9D4D25B07", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.4e1"}], "value"=>"4", "displayOrder"=>0.4e1, "text"=>"Quite a bit"}, {"id"=>"74DC8842-078A-4DC6-B9C9-1656A8775657", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.5e1"}], "value"=>"5", "displayOrder"=>0.5e1, "text"=>"Very much"}], "item"=>[]}]}, {"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.21e2"}], "displayOrder"=>0.21e2, "linkId"=>"PAININ31", "text"=>nil, "code"=>[], "type"=>"group", "answerOption"=>[], "item"=>[{"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.1e1"}], "displayOrder"=>0.1e1, "linkId"=>"8AB8BA58-3BB0-40B6-B656-C24F1169069B", "text"=>"In the past 7 days", "code"=>[], "type"=>"display", "answerOption"=>[], "item"=>[]}, {"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.2e1"}], "displayOrder"=>0.2e1, "linkId"=>"D7909665-A8AB-4C99-9C0B-2E3D67FA8D86", "text"=>"How much did pain interfere with your ability to participate in social activities?", "code"=>[], "type"=>"display", "answerOption"=>[], "item"=>[]}, {"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.3e1"}], "displayOrder"=>0.3e1, "linkId"=>"B8630087-5995-4B62-8BE1-55BDEA27A80A", "text"=>nil, "code"=>[], "type"=>"choice", "answerOption"=>[{"id"=>"949D2A4E-3A2B-4CD6-BE45-33C56EA76813", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.1e1"}], "value"=>"1", "displayOrder"=>0.1e1, "text"=>"Not at all"}, {"id"=>"7C45E84C-87A5-410B-BF19-29D75531EFF4", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.2e1"}], "value"=>"2", "displayOrder"=>0.2e1, "text"=>"A little bit"}, {"id"=>"441EE176-E592-4B32-B5FE-83B738EB10BA", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.3e1"}], "value"=>"3", "displayOrder"=>0.3e1, "text"=>"Somewhat"}, {"id"=>"29BD9E0E-298C-4A51-99C3-48B9D4D25B07", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.4e1"}], "value"=>"4", "displayOrder"=>0.4e1, "text"=>"Quite a bit"}, {"id"=>"74DC8842-078A-4DC6-B9C9-1656A8775657", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>"0.5e1"}], "value"=>"5", "displayOrder"=>0.5e1, "text"=>"Very much"}], "item"=>[]}]}]}],
          meta: { 'profile' => [ 'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaireresponse-adapt' ] },
          primary_key: current_user.id,
          sort_key: 'quest-resp_abc',
          questionnaire_id: '154D0273-C3F6-4BCE-8885-3194D4CC4596',
          status: 'in-progress'
        )

        expect(full.items).to be_nil
        answer = { item:{ linkId: 'PAININ9', answer: [{ value: 'Somewhat' }]}}
        post "QuestionnaireResponses/#{full.id}/next-q", answer.to_json
        expect(last_response.status).to eq 200
        body = JSON.parse(last_response.body)
        item = body['questionnaireItem']
        expect(item['linkId']).to eq 'PAININ31'
        qr = Db.find_questionnaire_response(current_user.id, full.id)
        expect(qr.item.size).to eq 1

        answer = { item:{ linkId: 'PAININ9', answer: [{ value: 'A little bit' }]}}
        post "QuestionnaireResponses/#{full.id}/next-q", answer.to_json
        expect(last_response.status).to eq 200
        body = JSON.parse(last_response.body)
        item = body['questionnaireItem']
        expect(item['linkId']).to eq 'PAININ31'
        qr = Db.find_questionnaire_response(current_user.id, full.id)
        expect(qr.item.size).to eq 1
        expect(qr.items.first.answers.first.valueString).to eq 'A little bit'
      end
    end

    describe 'GET /result' do
      it 'does nothing' do
        get 'QuestionnaireResponses/1/result'
        expect(last_response.status).to eq 200
      end
    end
  end

  context 'FhirSDC' do
    before(:all) do
      PromisAPI.reset!
      @prev_api_type = $config['promis_api_type']
      $config['promis_api_type'] = 'FhirSDC'
    end

    after(:all) do
      $config['promis_api_type'] = @prev_api_type
      PromisAPI.reset!
    end

    describe 'GET /next-q' do
      it 'initializes a questionnaire if needed', :vcr do
        get "QuestionnaireResponses/#{empty.id}/next-q"
        expect(last_response.status).to eq 200

        body = JSON.parse(last_response.body)
        q = body['questionnaireItem']
        expect(q['linkId']).to eq 'C595E017-42B2-4093-9C3E-B338B22E4FE4'

        qr = Db.find_questionnaire_response(current_user.id, empty.id)

        expect(qr.contained[0]['item'][0]['linkId']).to eq \
          'C595E017-42B2-4093-9C3E-B338B22E4FE4'
      end

      it 'returns the latest question if there is an unanswered question' do
        empty.contained = [
          {
            'resourceType' => 'Questionnaire',
            'id' => '154D0273-C3F6-4BCE-8885-3194D4CC4596',
            'item' => [
              {
                'linkId' => 'PAININ9',
                'type' => 'group',
                'answerOption' => []
              }
            ]
          }
        ]
        empty.save! force: true

        get "QuestionnaireResponses/#{empty.id}/next-q"

        body = JSON.parse(last_response.body)
        q = body['questionnaireItem']
        expect(q['linkId']).to eq 'PAININ9'
      end
    end

    describe 'POST /next-q' do
      it "can't answer if there's no question" do
        answer = {
          item: {
            linkId: 'C595E017-42B2-4093-9C3E-B338B22E4FE4',
            answer: [{ value: 'Somewhat' }]
          }
        }

        post "QuestionnaireResponses/#{empty.id}/next-q", answer.to_json

        expect(last_response.status).to eq 400

        qr = Db.find_questionnaire_response(current_user.id, empty.id)
        expect(qr.item).to be_nil
      end

      it 'answers a question and returns the next question', :vcr do
        full.contained = [{"id"=>"154D0273-C3F6-4BCE-8885-3194D4CC4596", "title"=>nil, "status"=>nil, "item"=>[{"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>0.1e1}], "id"=>"PAININ9", "linkId"=>"C595E017-42B2-4093-9C3E-B338B22E4FE4", "code"=>[{"system"=>"http://loinc.org", "display"=>"In the past 7 daysHow much did pain interfere with your day to day activities?", "code"=>"61758-9"}], "type"=>"group", "item"=>[{"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>0.1e1}], "linkId"=>"8AB8BA58-3BB0-40B6-B656-C24F1169069B", "text"=>"In the past 7 days", "type"=>"display"}, {"extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>0.2e1}], "linkId"=>"5B10732E-3A51-438C-A437-B07E2CFBE71A", "text"=>"How much did pain interfere with your day to day activities?", "type"=>"choice", "answerOption"=>[{"id"=>"DC8FFD51-702B-4E77-BEE6-E9A9EB9C088F", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>0.1e1}], "modifierExtension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-optionScore", "valueString"=>"1"}], "text"=>"Not at all", "valueCoding"=>{"system"=>"http://loinc.org", "display"=>"Not at all", "code"=>"LA6568-5"}}, {"id"=>"72A3573B-E0C3-4358-AF57-858F11A0ED49", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>0.2e1}], "modifierExtension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-optionScore", "valueString"=>"2"}], "text"=>"A little bit", "valueCoding"=>{"system"=>"http://loinc.org", "display"=>"A little bit", "code"=>"LA13863-8"}}, {"id"=>"C31A3FCB-A380-444F-8579-62AA5DA11BA2", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>0.3e1}], "modifierExtension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-optionScore", "valueString"=>"3"}], "text"=>"Somewhat", "valueCoding"=>{"system"=>"http://loinc.org", "display"=>"Somewhat", "code"=>"LA13909-9"}}, {"id"=>"FCD65655-AA94-44B6-B944-2994D984A4E3", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>0.4e1}], "modifierExtension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-optionScore", "valueString"=>"4"}], "text"=>"Quite a bit", "valueCoding"=>{"system"=>"http://loinc.org", "display"=>"Quite a bit", "code"=>"LA13902-4"}}, {"id"=>"1F43076B-0B6B-4D91-8B3C-EF6E39F9CF18", "extension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-displayOrder", "valueInteger"=>0.5e1}], "modifierExtension"=>[{"url"=>"http://hl7.org/fhir/StructureDefinition/questionnaire-optionScore", "valueString"=>"5"}], "text"=>"Very much", "valueCoding"=>{"system"=>"http://loinc.org", "display"=>"Very much", "code"=>"LA13914-9"}}]}]}], "subjectType"=>["Patient"], "date"=>nil, "meta"=>{"versionId"=>nil, "lastUpdated"=>nil, "profile"=>["http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-adapt"]}, "url"=>nil, "resourceType"=>"Questionnaire"}]
        full.save! force: true

        answer = {
          item: {
            linkId: 'C595E017-42B2-4093-9C3E-B338B22E4FE4',
            answer: [{ value: 'Somewhat' }]
          }
        }

        post "QuestionnaireResponses/#{full.id}/next-q", answer.to_json

        expect(last_response.status).to eq 200

        body = JSON.parse(last_response.body)
        item = body['questionnaireItem']

        expect(item['linkId']).to eq '4022007D-41E8-4B28-8100-5A2D544DC699'

        qr = Db.find_questionnaire_response(current_user.id, full.id)
        expect(qr.item.size).to eq 1
        expect(qr.item[0]['extension'][0]['valueInteger']).to eq 1
        expect(qr.contained[0]['item'].size).to eq 2
        expect(qr.item[0]['linkId']).to eq \
          'C595E017-42B2-4093-9C3E-B338B22E4FE4'
        expect(qr.contained[0]['item'][1]['linkId']).to eq \
          'C595E017-42B2-4093-9C3E-B338B22E4FE4'
        expect(qr.contained[0]['item'][0]['linkId']).to eq \
          '4022007D-41E8-4B28-8100-5A2D544DC699'
      end

      it 'handles answers for previous questions', :vcr do
        answer = {
          item: {
            linkId: 'DEE2D9CA-0094-492A-AA25-D4D53D426976',
            answer: [{ value: 'Always'}]
          }
        }

        expect(almost_complete.questionnaire.items.size).to eq 10
        # it has 10 answers because, if posted, it would finish the
        # questionnaire
        expect(almost_complete.items.size).to eq 10

        post "QuestionnaireResponses/#{almost_complete.id}/next-q",
          answer.to_json

        expect(last_response.status).to eq 200

        body = JSON.parse(last_response.body)
        item = body['questionnaireItem']

        expect(item['linkId']).to eq 'F1BBB664-7C68-49EC-AB50-767CDFD947BA'

        qr = Db.find_questionnaire_response(current_user.id,
                                            almost_complete.id)

        expect(qr.questionnaire.items.size).to eq 2
        expect(qr.items.size).to eq 1
        expect(qr.containeds[0].items[0].linkId).to eq \
          'F1BBB664-7C68-49EC-AB50-767CDFD947BA'
        expect(qr.containeds[0].items[1].linkId).to eq \
          'DEE2D9CA-0094-492A-AA25-D4D53D426976'
        expect(qr.unanswered_question.linkId).to eq \
          'F1BBB664-7C68-49EC-AB50-767CDFD947BA'
      end

      context 'with async archive ON' do
        before do
          @orig = ENV['ASYNC_ARCHIVE']
          ENV['ASYNC_ARCHIVE'] = 'true'
        end

        after { ENV['ASYNC_ARCHIVE'] = @orig }

        it 'finishes a questionnaire and adds population comparison', :vcr do
          client = Aws::Lambda::Client.new(region: 'us-east-1')
          expect(Aws::Lambda::Client).to receive(:new).and_return(client)
          expect(client).to receive(:invoke)

          allow(DateTime).to receive(:now) { DateTime.new(2019, 6, 26) }

          answer = {
            item: {
              linkId: '12FC21DA-6160-4ADF-9528-0A75A40E6FFA',
              answer: [{ value: 'Always'}]
            }
          }

          bday = Date.new(Date.today.year - 50, Date.today.month, Date.today.day)
          patient = Models::Patient.new(
            primary_key: current_user.id,
            _fhir_access_data: { access_token: ENV['TEST_HUB_AUTH_TOKEN'] },
            name: [{ given: 'John', family: 'Doe' }],
            organization_id: SecureRandom.uuid,
            gender: 'male',
            birthDate: bday
          )
          patient.save! force: true

          post "QuestionnaireResponses/#{almost_complete.id}/next-q",
            answer.to_json

          expect(last_response.status).to eq 200

          body = JSON.parse(last_response.body)
          item = body['questionnaireItem']

          expect(item).to eq([])

          qr = Db.find_questionnaire_response(current_user.id,
                                              almost_complete.id)

          expect(qr).to be_completed
          expect(qr.population_comparison.with_indifferent_access).to eq(
            'age' => {
              'description' => '45 <= age < 55',
              'value' => 99
            },
            'gender' => {
              'description' => 'male',
              'value' => 99
            },
            'total' => 99
          )

          get "QuestionnaireResponses/#{almost_complete.id}"

          body = JSON.parse(last_response.body, symbolize_names: true)
          raw = body[:questionnaireResponses]

          expect(raw[:population_comparison]).to eq(
            age: {
              description: '45 <= age < 55',
              value: 99
            },
            gender: {
              description: 'male',
              value: 99
            },
            total: 99
          )
        end
      end

      context 'with async archive OFF' do
        before do
          @orig = ENV['ASYNC_ARCHIVE']
          ENV['ASYNC_ARCHIVE'] = nil
        end

        after { ENV['ASYNC_ARCHIVE'] = @orig }

        it 'finishes a questionnaire and adds population comparison', :vcr do
          client = Archive::Client.new(auth_token: 'abc_123')
          expect(Archive::Client).to receive(:new).and_return(client)
          expect(client).to receive(:archive)

          allow(DateTime).to receive(:now) { DateTime.new(2019, 6, 26) }

          answer = {
            item: {
              linkId: '12FC21DA-6160-4ADF-9528-0A75A40E6FFA',
              answer: [{ value: 'Always'}]
            }
          }

          bday = Date.new(Date.today.year - 50, Date.today.month, Date.today.day)
          patient = Models::Patient.new(
            primary_key: current_user.id,
            _fhir_access_data: { access_token: ENV['TEST_HUB_AUTH_TOKEN'] },
            name: [{ given: 'John', family: 'Doe' }],
            organization_id: SecureRandom.uuid,
            gender: 'male',
            birthDate: bday
          )
          patient.save! force: true

          post "QuestionnaireResponses/#{almost_complete.id}/next-q",
            answer.to_json

          expect(last_response.status).to eq 200

          body = JSON.parse(last_response.body)
          item = body['questionnaireItem']

          expect(item).to eq([])

          qr = Db.find_questionnaire_response(current_user.id,
                                              almost_complete.id)

          expect(qr).to be_completed
          expect(qr.population_comparison.with_indifferent_access).to eq(
            'age' => {
              'description' => '45 <= age < 55',
              'value' => 99
            },
            'gender' => {
              'description' => 'male',
              'value' => 99
            },
            'total' => 99
          )

          get "QuestionnaireResponses/#{almost_complete.id}"

          body = JSON.parse(last_response.body, symbolize_names: true)
          raw = body[:questionnaireResponses]

          expect(raw[:population_comparison]).to eq(
            age: {
              description: '45 <= age < 55',
              value: 99
            },
            gender: {
              description: 'male',
              value: 99
            },
            total: 99
          )
        end
      end

      context 'error' do
        before do
          s = Socket.new(:INET, :STREAM, 0)
          s.bind(Addrinfo.tcp('127.0.0.1', 0))
          port = s.getsockname.unpack('snA*')[1]
          s.close
          @orig_hub_url = ENV['HUB_FHIR_URL']
          ENV['HUB_FHIR_URL'] = "http://localhost:#{port}"
        end

        after do
          ENV['HUB_FHIR_URL'] = @orig_hub_url
        end

        it 'finishes a questionnaire but archiving not available', :vcr do
          answer = {
            item: {
              linkId: '12FC21DA-6160-4ADF-9528-0A75A40E6FFA',
              answer: [{ value: 'Always'}]
            }
          }

          bday = Date.new(Date.today.year - 50, Date.today.month, Date.today.day)
          patient = Models::Patient.new(primary_key: current_user.id,
                                        _fhir_access_data: {
                                          access_token: ENV['TEST_HUB_AUTH_TOKEN']
                                        },
                                        name: [{ given: 'John', family: 'Doe' }],
                                        organization_id: SecureRandom.uuid,
                                        gender: 'male',
                                        birthDate: bday)
          patient.save! force: true

          expect do
            post "QuestionnaireResponses/#{almost_complete.id}/next-q",
              answer.to_json
          end.to raise_error
        end
      end
    end

    describe 'GET /result' do
      it 'does nothing' do
        get 'QuestionnaireResponses/1/result'
        expect(last_response.status).to eq 200
      end
    end
  end
end
