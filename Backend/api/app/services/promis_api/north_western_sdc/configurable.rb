module PromisAPI::NorthWesternSDC
  module Configurable
    attr_accessor :username, :password

    class << self
      def keys
        @keys ||= [
          :username,
          :password,
          :api_endpoint,
          :api_type
        ]
      end
    end
  end
end
