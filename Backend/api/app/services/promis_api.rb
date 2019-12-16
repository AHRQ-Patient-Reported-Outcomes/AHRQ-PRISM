require_relative 'promis_api/north_western_sdc/client'
require_relative 'promis_api/north_western_sdc/default'

module PromisAPI
  class << self
    def client(options = {})
      @client ||= "PromisAPI::#{$config['promis_api_type']}::Client"
        .constantize
        .new(options)
    end
  end
end
