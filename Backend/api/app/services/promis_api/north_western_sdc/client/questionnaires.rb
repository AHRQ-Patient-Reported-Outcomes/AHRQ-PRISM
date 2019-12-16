# frozen_string_literal: true

module PromisAPI
  module NorthWesternSDC
    class Client
      module Questionnaires
        # List Questionnaires Available
        #
        def questionnaires
          get('/Forms/.json')
        end

        # This returns a specific Questionnaire
        #
        # {
        #   "DateFinished": nil,
        #   "Items": [
        #     {
        #
        #     }
        #     ...
        #   ]
        # }
        def questionnaire(id)
          get("/Forms/#{id}.json")
        end
      end
    end
  end
end
