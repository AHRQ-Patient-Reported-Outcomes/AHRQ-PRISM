require 'spec_helper'

describe PromisAPI::NorthWesternSDC::Client do
  describe 'initialize' do
    it 'creates a client' do
      client = PromisAPI::NorthWesternSDC::Client.new(username: 'doug-debold', password: 'foobar')

      expect(client.inspect[:username]).to eq 'doug-debold'
      expect(client.inspect[:password]).to eq '*********'
    end
  end
end
