#  frozen_string_literal: true

require_relative './controller_base'
require_relative '../services/promis_api'

class QuestionnaireResponsesController < ControllerBase
  get '/QuestionnaireResponses' do
    param :status, String, required: true

    questionnaire_responses = Db.get_questionnaire_response_by_patient(
      current_user.id,
      params[:status]
    ).map(&:serializable_hash)

    json questionnaireResponses: questionnaire_responses
  end

  namespace '/QuestionnaireResponses' do
    get '/:id' do
      questionnaire_response = Db.find_questionnaire_response(current_user.id, params[:id])

      json questionnaireResponses: questionnaire_response
    end

    namespace '/:id' do
      get '/reset' do
        qr = Db.find_questionnaire_response(current_user.id, params[:id])
        qr.reset
        qr.save

        json success: true
      end

      post '/archive' do
        sleep 1 # Low, potential for race conditions, but avoid anyways
        qr = Db.find_questionnaire_response(current_user.id, params[:id])
        patient = Models::Patient.find(qr.primary_key)

        raise 'Missing patient' unless patient

        Archive::Client.new(auth_token: patient.fhir_access_data&.access_token).archive(qr)

        json success: true
      end

      get '/next-q' do
        quest_resp = Db.find_questionnaire_response(current_user.id, params[:id])
        handle_get_next_question(quest_resp)

        json questionnaireItem: quest_resp.unanswered_question || []
      end

      # params: {
      #   linkId: 'linkId',
      #   text: 'text',
      #   answer: [
      #     { value: 'somewhat' }
      #   ]
      # }
      post '/next-q' do
        answer = JSON.parse(request.body.read)['item']

        quest_resp = Db.find_questionnaire_response(current_user.id, params[:id])

        questionnaire = quest_resp.questionnaire
        # return 400 if there's no questionnaire to answer
        halt 400 if questionnaire.nil?
        q = questionnaire.items&.find { |i| i.linkId == answer['linkId'] }
        # return 400 if there's no question in the questionnaire to answer
        halt 400 if q.nil?

        if q.displayOrder < questionnaire.item.size
          quest_resp.remove_after_index(q.displayOrder)
        end

        quest_resp.add_answer(
          answer['linkId'],
          answer['answer'].map { |ans| ans['value'] }
        )
        quest_resp.save

        handle_get_next_question(quest_resp)

        json questionnaireItem: quest_resp.unanswered_question || []
      end

      get '/result' do
        json foo: 'bar'
      end
    end
  end

  private

  def handle_get_next_question(quest_resp)
    return unless quest_resp.unanswered_question.nil?

    changes = PromisAPI.client.next_question(questionnaire_response: quest_resp)
    quest_resp.update!(changes)

    handle_questionnaire_over(quest_resp) if quest_resp.completed?
  end

  def handle_questionnaire_over(qr)
    qr.authored = DateTime.now.to_date
    patient = Models::Patient.find(qr.primary_key)

    # Add population comparison data
    add_population_comparison_data(qr, patient)

    # Add the historical comparison data
    add_history_comparison(qr, current_user)

    qr.save

    # Archive the questionnaire response to the Hub
    # Moved this to after the save to avoid race condition
    archive_questionnaire(qr, current_user, patient)

    true
  end

  def archive_questionnaire(qr, current_user, patient)
    if ENV['ASYNC_ARCHIVE'] == 'true'
      Aws::Lambda::Client.new(region: 'us-east-1').invoke(
        function_name: ENV['FUNCTION_NAME'],
        invocation_type: 'Event',
        payload: JSON.generate({
          path: "QuestionnaireResponses/#{qr.id}/archive",
          httpMethod: "POST",
          headers: { content_type: "application/json" },
          requestContext: {
            identity: {
              cognitoIdentityId: current_user.id
            }
          }
        })
      )
    else
      Archive::Client.new(auth_token: patient.fhir_access_data&.access_token).archive(qr)
    end
  end

  def add_history_comparison(qr, current_user)
    responses = Db.get_questionnaire_response_by_patient(current_user.id, 'completed')
      .keep_if { |i| i.id != qr.id }

    unless responses.empty?
      is_highest_ever = responses.max_by { |x| x.theta }.theta < qr.theta
      is_lowest_ever = responses.min_by { |x| x.theta }.theta > qr.theta
      last_response = responses.sort { |x, y| y.authored <=> x.authored }.first

      qr.result_modal_data = {
        timeSinceLast: (qr.authored - last_response.authored).to_i,
        diff: (qr.t_score - last_response.t_score).round.to_i,
        isHighestEver: is_highest_ever,
        isLowestEver: is_lowest_ever
      }
    end
  end

  def add_population_comparison_data(qr, patient)
    if patient
      bday = patient.birthDate
      age = patient.birthDate.upto(Date.today).select do |date|
        date.day == bday.day && date.month == bday.month
      end.size - 1

      qr.population_comparison = Population.get_percentiles(
        form_id: qr.actual_questionnaire_id,
        t_score: qr.t_score,
        gender: patient.gender,
        age: age
      )
    else
      logger.error("Could not find patient record, skipping population comparison")
    end
  end
end
