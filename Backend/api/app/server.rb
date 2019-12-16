# frozen_string_literal: true

# Load Application and environment variables
# This should be first
require_relative 'application'

require 'aws-record'

require_relative 'base'

# Load the controllers
require_relative 'controllers/questionnaire_responses_controller'
require_relative 'controllers/questionnaires_controller'
require_relative 'controllers/patients_controller'

# Load PromisAPI wrapper
require_relative 'services/promis_api'

# Load DB
require_relative 'db'

# Rack::Cors
require 'rack/cors'

class PrismAPI < Base
  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: :any
    end
  end

  get '/' do
    json patient: true
  end

  use QuestionnaireResponsesController
  use QuestionnairesController
  use PatientsController
end
