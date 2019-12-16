# frozen_string_literal: true

namespace :prism_app do
  namespace :db do
    desc 'Setup local dynamoDB table'
    task :setup do
      client = Aws::DynamoDB::Client.new(
        region: 'local',
        access_key_id: 'anykey-or-xxx',
        secret_access_key: 'anykey-or-xxx',
        endpoint: "http://#{ENV['DYNAMO_LOCATION'] || 'localhost:8000'}"
      )

      unless client && client.config.region == 'local'
        puts 'Can only be run locally'
        return
      end
      if client.list_tables[:table_names].include?('PrismLocal')
        puts 'Table Exists'
        return
      end

      table_name = ENV['DYNAMO_TABLE_NAME'] || 'PrismLocal'

      STDOUT.puts "Creating table with name: #{table_name}"

      client.create_table(
        attribute_definitions: [
          {
            attribute_name: 'primaryKey',
            attribute_type: 'S'
          },
          {
            attribute_name: 'sortKey',
            attribute_type: 'S'
          }
        ],
        key_schema: [
          {
            attribute_name: 'primaryKey',
            key_type: 'HASH'
          },
          {
            attribute_name: 'sortKey',
            key_type: 'RANGE'
          }
        ],
        provisioned_throughput: {
          read_capacity_units: 5,
          write_capacity_units: 5
        },
        table_name: table_name
      )
    end
  end
end
