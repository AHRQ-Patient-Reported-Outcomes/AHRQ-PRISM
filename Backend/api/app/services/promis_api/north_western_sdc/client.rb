# frozen_string_literal: true

# Setup, defaults and base stuff
require_relative 'connection'
require_relative 'configurable'

# Adapters
require_relative 'client/questionnaire_response'
require_relative 'client/questionnaires'

module PromisAPI
  module NorthWesternSDC
    class Client
      include PromisAPI::NorthWesternSDC::Configurable
      include PromisAPI::NorthWesternSDC::Connection

      include PromisAPI::NorthWesternSDC::Client::QuestionnaireResponse
      include PromisAPI::NorthWesternSDC::Client::Questionnaires

      def initialize(options = {})
        PromisAPI::NorthWesternSDC::Configurable.keys.each do |key|
          instance_variable_set(:"@#{key}", PromisAPI::NorthWesternSDC::Default.options[key])
        end

        PromisAPI::NorthWesternSDC::Configurable.keys.each do |key|
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

      def foobar
        puts 'hi'
      end
    end
  end
end
