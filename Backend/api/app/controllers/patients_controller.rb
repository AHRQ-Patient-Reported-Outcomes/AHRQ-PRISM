#  frozen_string_literal: true

require_relative './controller_base'

class PatientsController < ControllerBase
  namespace '/Patients' do
    get '/current' do
      patient = Db.get_patient_by_id(current_user.id)

      json patient: patient
    end
  end
end
