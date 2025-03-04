module Twilio
  class SendSmsService
    def initialize(to:, from:, body:)
      @to = to
      @from = from
      @body = body
    end

    def call
      client = create_client

      output = client.messages.create(
        from: @from,
        to: @to,
        body: @body
      )

      SendSmsServiceResponse.new(
        success: true,
        message_sid: output.sid,
        error_code: nil,
        error_message: nil
      )
    rescue Twilio::REST::RestError => e
      error_data = JSON.parse(e.response.body)
      SendSmsServiceResponse.new(
        success: false,
        message_sid: nil,
        error_code: error_data['code'],
        error_message: error_data['message']
      )
    rescue StandardError => e
      SendSmsServiceResponse.new(
        success: false,
        message_sid: nil,
        error_code: nil,
        error_message: e.message
      )
    end

    private

    def create_client
      Twilio::REST::Client.new(
        Rails.application.credentials.twilio[:account_sid],
        Rails.application.credentials.twilio[:auth_token]
      )
    end
  end

  class SendSmsServiceResponse < Data.define(:success, :message_sid, :error_code, :error_message)
  end
end
