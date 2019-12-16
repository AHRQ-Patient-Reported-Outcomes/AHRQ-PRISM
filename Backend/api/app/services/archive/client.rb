module Archive
  ##
  # Client for archiving questionnaire responses after they're completed.
  class Client

    def initialize(auth_token:)
      headers = {
        'Authorization' => "Bearer #{auth_token}"
      }

      STDOUT.puts "Base URL: #{base_url}"

      @connection = Faraday.new(url: base_url, headers: headers) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def archive(questionnaire_response)
      _start = Time.now
      resp = @connection.post do |req|
        _start1 = Time.now
        req.url 'QuestionnaireResponse'
        req.headers['Content-Type'] = 'application/json;charset=utf-8'

        fhir_obj = serializer.to_fhir(questionnaire_response)
        errors = fhir_obj.validate

        # Need to convert into instant for google
        # TODO Save in dynamo correctly
        if errors.dig('contained', 0, 'meta', 0, 'lastUpdated')
          str = fhir_obj.contained[0].meta.lastUpdated
          fhir_obj.contained[0].meta.lastUpdated = Time.parse(str).strftime('%Y-%M-%dT%H:%M:%S.0+00:00')
        end

        _end1 = Time.now
        STDOUT.puts("TIME_next-q#faraday-setup_p1 #{(_end1 - _start1) * 1000}ms")

        _start1 = Time.now
        # Check for anymore errors
        errors = fhir_obj.validate
        if !errors.empty?
          STDOUT.puts("QR Archive Validation Errors #{errors.to_json}")
        end
        _end1 = Time.now
        STDOUT.puts("TIME_next-q#faraday-setup_p2 #{(_end1 - _start1) * 1000}ms")

        _start1 = Time.now
        req.body = fhir_obj.to_json
        _end1 = Time.now
        STDOUT.puts("TIME_next-q#faraday-setup_p3 #{(_end1 - _start1) * 1000}ms")
      end

      _end = Time.now
      STDOUT.puts("TIME_next-q#archive-post #{(_end - _start) * 1000}ms")

      if !resp.status.to_s.match(/2[0-9]{2}/)
        STDOUT.puts("Error archiving QR #{questionnaire_response.id} to Hub")
        STDOUT.puts("Status: #{resp.status}, Body: #{resp.body}")
        STDOUT.puts("Request Body, #{serializer.to_fhir(questionnaire_response).to_json}")
      else
        STDOUT.puts("Successful archiving. Status: #{resp.status}")
      end

      resp
    end

    private

    def serializer
      Archive::QuestionnaireResponseSerializer
    end

    def base_url
      ENV['HUB_FHIR_URL']
    end
  end
end
