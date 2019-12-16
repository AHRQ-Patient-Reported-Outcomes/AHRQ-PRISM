require 'spec_helper'

describe 'Test DB' do
  before :all do
    @quest_resp_id = 'questResp-abc'
    @questionnaire_id = '154D0273-C3F6-4BCE-8885-3194D4CC4596'

    Models::QuestionnaireResponse.new(
      primary_key: current_user.id,
      sort_key: 'questResp-abc',
      questionnaire_id: '154D0273-C3F6-4BCE-8885-3194D4CC4596',
      item: [],
      status: 'in-progress'
    ).save
  end

  after :all do
    Db.find_questionnaire_response(current_user.id, @quest_resp_id).delete!
  end

  it 'worked' do
    quest_resp = Db.find_questionnaire_response(current_user.id, @quest_resp_id)

    expect(quest_resp.id).to eq @quest_resp_id
  end
end
