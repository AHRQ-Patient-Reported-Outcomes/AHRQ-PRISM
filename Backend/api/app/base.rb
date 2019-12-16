# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'
require 'sinatra/reloader'

class Base < Sinatra::Application
  configure :development, :test do
    register Sinatra::Reloader

    $dynamo_local = Aws::DynamoDB::Client.new(
      region: 'local',
      access_key_id: 'anykey-or-xxx',
      secret_access_key: 'anykey-or-xxx',
      endpoint: 'http://db:8000'
    )
  end
end
