module PromisAPI::NorthWesternSDC
  module Default
    API_ENDPOINT = 'https://www.assessmentcenter.net/ac_api/2014-01'.freeze

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
        Hash[PromisAPI::NorthWesternSDC::Configurable.keys.map{ |key| [key, send(key)] }]
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
        # 'NorthWesternSDC' || 'FhirSDC'
        $config['promis_api_type']
      end
    end
  end
end
