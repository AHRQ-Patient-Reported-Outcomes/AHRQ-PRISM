require 'spec_helper'

describe PromisAPI::NorthWesternSDC::Client do
  let(:client) { PromisAPI::NorthWesternSDC::Client.new }

  describe 'questionnaires' do
    it 'lists questionnaires', :vcr do
      resp = client.questionnaires

      expect(resp[:body].keys).to eq ['Form']
    end
  end

  describe 'questionnaire' do
    it 'works for getting a single questionnaire', :vcr do
      resp = client.questionnaire('97EF3938-4CDC-4192-B2E0-54D71EABC3DE')

      expect(resp[:body]['Items'].size).to eq 10
    end
  end
end
