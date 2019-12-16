require 'active_model'

module Models
  class CurrentUser
    include ActiveModel::Model

    attr_accessor :id

    def initialize(attrs = {})
      @id = attrs['cognitoIdentityId'] || attrs[:cognitoIdentityId]
      # @id = 'us-east-1:ebba4487-9a35-49e2-9c54-9a6db313a679' # wilma smart
      # @id = 'us-east-1:3be73ad0-db63-4c33-b31b-703fa00bde9a' # joe smart
    end
  end
end
