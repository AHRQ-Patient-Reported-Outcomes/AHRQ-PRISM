require 'spec_helper'

RSpec.describe Archive::Client do
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

  it 'archives FHIR', :vcr do
    res = Archive::Client.new(auth_token: ENV['TEST_HUB_AUTH_TOKEN'])
                         .archive(almost_complete)
    expect(res.success?).to be true
  end
end
