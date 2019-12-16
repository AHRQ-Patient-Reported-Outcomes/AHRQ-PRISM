ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'pry'
require 'webmock/rspec'
require 'vcr'

require_relative '../boot.rb'

VCR.configure do |config|
  config.ignore_hosts 'db', '127.0.0.1', 'localhost'
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    match_requests_on: %i[method uri body]
  }

  config.before_record do |i|
    i.request.headers.delete('Authorization')
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before :each do
    env('rack.session', mock_session)

    # Stub Responses
    Models::Organization.configure_client(client: local_client)
    Models::Patient.configure_client(client: local_client)
    Models::Questionnaire.configure_client(client: local_client)
    Models::QuestionnaireResponse.configure_client(client: local_client)
    Models::ScoreHistory.configure_client(client: local_client)
  end
end

def local_client
  @local_client ||= begin
    Aws::DynamoDB::Client.new(
      region: 'local',
      access_key_id: 'anykey-or-xxx',
      secret_access_key: 'anykey-or-xxx',
      endpoint: "http://#{ENV['DYNAMO_LOCATION'] || 'localhost:8000'}"
    )
  end
end

def app; PrismAPI end

def file_fixture(fname)
  Pathname.new(File.dirname(__FILE__)).join('fixtures', fname)
end

# We could use native RSpec `post '/endpoint', param1: 'foo', param2: 'bar'
# But this method better replicates how AWS API Gateway forwards the request
# to our AWS Lamda function: In './lambda.rb' needs to reset `rack.input` with
# JSON string Lambda event body.
def api_gateway_post(path, params)
  api_gateway_body_fwd = params.to_json
  rack_input = StringIO.new(api_gateway_body_fwd)

  post path, real_params = {}, 'rack.input' => rack_input
end

def json_result
  JSON.parse(last_response.body)
end

def mock_session
  {
    'cognitoIdentityPoolId' => 'us-east-1:abc_123',
    'accountId' => 'abc_123',
    'cognitoIdentityId' => 'us-east-1:abc_123_user_id',
    'caller' => 'abc_123:CognitoIdentityCredentials',
    'sourceIp' => 'abc_123_ip',
    'accessKey' => 'abc_123',
    'cognitoAuthenticationType' => 'authenticated',
    'cognitoAuthenticationProvider' => 'authorization.sandboxcerner.com/tenants/abc_123/oidc/idsps/abc_123,arn:aws:iam::764437882157:oidc-provider/authorization.sandboxcerner.com/tenants/abc_123/oidc/idsps/abc_123',
    'userArn' => 'arn:aws:sts::abc_123:assumed-role/Cognito_TestSmartFHIRLauncherAuth_Role/CognitoIdentityCredentials',
    'userAgent' => 'Mozilla/5.0',
    'user' => 'abc_123:CognitoIdentityCredential'
  }
end

def current_user
  Models::CurrentUser.new(mock_session)
end
