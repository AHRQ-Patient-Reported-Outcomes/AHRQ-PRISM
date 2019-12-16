# 1 Determine ENV
ENV['SINATRA_ENV'] ||= ENV['RACK_ENV'] ||= 'development'

ENV['DYNAMO_TABLE_NAME'] = 'PrismLocal'

if ENV['SINATRA_ENV'] == 'production'
  ENV['DYNAMO_TABLE_NAME'] = 'PrismApiTable'
end
