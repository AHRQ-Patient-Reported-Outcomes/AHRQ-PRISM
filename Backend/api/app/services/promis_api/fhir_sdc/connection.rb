# frozen_string_literal: true

require 'faraday_middleware'
require 'sawyer'

module PromisAPI::FhirSDC
  module Connection
    def get(url, _options = {})
      request(:get, url)
    end

    def post(url, options = {})
      request :post, url, options
    end

    def agent
      @agent || Faraday.new(url: 'https://www.assessmentcenter.net/') do |http|
        http.request :json
        http.response :json
        http.adapter :net_http
        http.basic_auth(@username, @password)
      end
    end

    def last_response
      @last_response if defined? @last_response
    end

    protected

    def endpoint
      @api_endpoint
    end

    private

    def request(method, path, data = {}, options = {})
      if data.is_a?(Hash)
        options[:query]   = data.delete(:query) || {}
        options[:headers] = data.delete(:headers) || {}
        if accept = data.delete(:accept)
          options[:headers][:accept] = accept
        end
      end

      uri = Addressable::URI.parse('/AC_API/2018-10' + path.to_s).normalize.to_s

      # @last_response = response = agent.send(method, uri, data.to_json)

      @last_response = response = if method == :post
                                    agent.post do |req|
                                      req.url uri
                                      req.body = data
                                    end
                                  else
                                    agent.send(method, uri)
                                  end

      # @last_response = response = agent.call(method, uri, data, options)

      {
        status: response.status,
        body: response.body
      }
    end

    def sawyer_options
      opts = {
        links_parser: Sawyer::LinkParsers::Simple.new
      }
      conn_opts = @connection_options
      conn_opts[:builder] = @middleware if @middleware
      conn_opts[:proxy] = @proxy if @proxy
      conn_opts[:ssl] = { verify_mode: @ssl_verify_mode } if @ssl_verify_mode
      opts[:faraday] = Faraday.new(conn_opts)

      opts
    end
  end
end
