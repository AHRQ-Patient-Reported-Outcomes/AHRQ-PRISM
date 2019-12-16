# frozen_string_literal: true

module PromisAPI::FhirSDC
  module Default
    API_ENDPOINT = 'https://www.assessmentcenter.net/AC_API/2018-10'

    RACK_BUILDER_CLASS = defined?(Faraday::RackBuilder) ? Faraday::RackBuilder : Faraday::Builder

    # Default Faraday middleware stack
    # MIDDLEWARE = RACK_BUILDER_CLASS.new do |builder|
    #   builder.use Faraday::Request::Retry, exceptions: [Octokit::ServerError]
    #   builder.use Octokit::Middleware::FollowRedirects
    #   builder.use Octokit::Response::RaiseError
    #   builder.use Octokit::Response::FeedParser
    #   builder.adapter Faraday.default_adapter
    # end

    class << self
      def options
        Hash[PromisAPI::FhirSDC::Configurable.keys.map { |key| [key, send(key)] }]
      end

      def api_endpoint
        ENV['PROMIS_API_ENDPOINT'] || API_ENDPOINT
      end

      def connection_options
        {}
      end

      def username
        ENV['PROMIS_API_USERNAME'] || 'test_user'
      end

      def password
        ENV['PROMIS_API_PASSWORD'] || nil
      end

      def api_type
        # 'FhirSDC' || 'FhirSDC'
        $config['promis_api_type']
      end
    end
  end
end
