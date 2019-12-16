# frozen_string_literal: true

# Setup, defaults and base stuff
require_relative 'connection'
require_relative 'configurable'

# Adapters
require_relative 'client/questionnaire_response'
require_relative 'client/questionnaires'

module PromisAPI
  module FhirSDC
    class Client
      include PromisAPI::FhirSDC::Configurable
      include PromisAPI::FhirSDC::Connection

      include PromisAPI::FhirSDC::Client::QuestionnaireResponse
      include PromisAPI::FhirSDC::Client::Questionnaires

      def initialize(options = {})
        PromisAPI::FhirSDC::Configurable.keys.each do |key|
          instance_variable_set(:"@#{key}", PromisAPI::FhirSDC::Default.options[key])
        end

        PromisAPI::FhirSDC::Configurable.keys.each do |key|
          value = options.key?(key) ? options[key] : instance_variable_get(:"@#{key}")

          instance_variable_set(:"@#{key}", value)
        end
        # Get and set auth keys for API Access
      end

      def inspect
        {
          username: @username,
          password: (@password ? '*********' : nil),
          api_endpoint: @api_endpoint
        }
      end
    end
  end
end
