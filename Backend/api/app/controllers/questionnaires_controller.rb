#  frozen_string_literal: true

require_relative '../base'

class QuestionnairesController < Base
  get '/questionnaires/:id/results' do
    body = {
      questionnaireResults: []
    }

    json body
  end
end
