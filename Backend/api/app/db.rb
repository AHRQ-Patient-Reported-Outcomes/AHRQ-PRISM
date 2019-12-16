# frozen_string_literal: true

require_relative 'models/patient'
require_relative 'models/organization'
require_relative 'models/questionnaire_response'
require_relative 'models/questionnaire'
require_relative 'models/score_history'

class Db
  class << self
    # ===================================================================
    # Patient Queries. Returns a single patient or an array of patients
    # ===================================================================
    def get_patient_by_id(id)
      Models::Patient.find(id)
    end

    def get_patient_by_organization(org_or_id)
      id = org_or_id.is_a?(String) ? org_or_id : org_or_id.primaryKey
      Models::Patient.for_organization(id)
    end

    # ===================================================================
    # QuestionnaireResponse Queries
    # ===================================================================
    def get_questionnaire_response_by_patient(patient, status_filter = nil)
      id = patient.is_a?(String) ? patient : patient.primaryKey

      Models::QuestionnaireResponse.for_patient(id, status_filter)
    end

    def find_questionnaire_response(patient_id, quest_resp_id)
      Models::QuestionnaireResponse.find(patient_id, quest_resp_id)
    end

    # ===================================================================
    # QuestionnaireResponse Queries
    # ===================================================================
    def get_score_history_by_patient_and_questionnaire

    end

    def get_score_history_by_patient_and_questionnaire

    end
  end
end
