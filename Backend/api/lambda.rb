# Lambda Entry Point

require 'json'
require 'rack'
require 'base64'

# Global object that responds to the call method. Stay outside of the handler
# to take advantage of container reuse
$app ||= Rack::Builder.parse_file("#{File.dirname(__FILE__)}/config.ru").first

def handler(event:, context:)
  body = decode_body(event: event)

  if event['path'].match(/need/)
    response = {
      'statusCode' => 200,
      'body' => event.to_json
    }

    return response
  end

  # Environment required by Rack (http://www.rubydoc.info/github/rack/rack/file/SPEC)
  env = build_env(event: event, body: body, context: context)

  # Pass request headers to Rack if they are available
  unless event['headers'].nil?
    event['headers'].each{ |key, value| env["HTTP_#{key}"] = value }
  end

  begin
    # Response from Rack must have status, headers and body
    status, headers, body = $app.call(env)

    # body is an array. We simply combine all the items to a single string
    body_content = ""
    body.each do |item|
      body_content += item.to_s
    end

    # We return the structure required by AWS API Gateway since we integrate with it
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

    headers['Access-Control-Allow-Origin'] = '*'

    {
      "statusCode" => status,
      "headers" => headers,
      "body" => body_content
    }
  rescue Exception => msg
    # If there is any exception, we return a 500 error with an error message
    {
      "statusCode" => 500,
      "body" => msg
    }
  end
end

private

def build_env(event:, body:, context:)
  # Rack expects the querystring in plain text, not a hash
  querystring = Rack::Utils.build_query(event['queryStringParameters']) if event['queryStringParameters']

  content_type = event['headers'] && event['headers']['content_type'] || ''

  # Environment required by Rack (http://www.rubydoc.info/github/rack/rack/file/SPEC)
  {
    'REQUEST_METHOD' => event['httpMethod'],
    'SCRIPT_NAME' => '',
    'PATH_INFO' => event['path'] || '',
    'QUERY_STRING' => querystring || '',
    'SERVER_NAME' => 'localhost',
    'SERVER_PORT' => 443,
    'CONTENT_TYPE' => content_type,

    'rack.version' => Rack::VERSION,
    'rack.url_scheme' => 'https',
    'rack.input' => StringIO.new(body || ''),
    'rack.errors' => $stderr,

    'rack.session' => build_session(event: event, context: context)
  }
end

def build_session(event:, context:)
  if event['requestContext']['authorizer']
    event['requestContext']['authorizer']['claims']
  elsif event['requestContext']['identity']
    event['requestContext']['identity']
  else
    raise 'We are missing things in the request context' + event['requestContext'].to_json
  end

end

def decode_body(event:)
  # Check if the body is base64 encoded. If it is, try to decode it
  if event['isBase64Encoded']
    Base64.decode64(event['body'])
  else
    event['body']
  end
end
