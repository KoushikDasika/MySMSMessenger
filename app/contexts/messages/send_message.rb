module Messages
  class SendMessage
    attr_accessor :to, :from, :body, :sms_response, :message

    def initialize(to:, from:, body:)
      @to = to
      @from = from
      @body = body
    end

    def call
      @message = create_message_with_users(@to, @from, @body)
      @sms_response = send_sms(@to, @from, @body)
      @message = update_message_with_sms_result(message, sms_response)

      SendMessageResponse.new(
        success: @sms_response.success,
        message: @message,
        error_code: @sms_response.error_code,
        error_message: @sms_response.error_message,
        sms_response: @sms_response
      )
    rescue Mongoid::Errors::Validations => e
      handle_error("validation_error", e)
    rescue StandardError => e
      handle_error(nil, e)
    end

    private

    def create_message_with_users(to, from, body)
      recipient = User.find_or_create_by(phone_number: to)
      sender = User.find_or_create_by(phone_number: from)

      Message.create!(
        to: to,
        from: from,
        body: body,
        success: false,
        recipient: recipient,
        sender: sender
      )
    end

    def send_sms(to, from, body)
      Apis::Twilio::SendSmsService.new(
        to: to,
        from: from,
        body: body
      ).call
    end

    def update_message_with_sms_result(message, sms_response)
        message.update!(
          success: sms_response.success,
          message_sid: sms_response.message_sid,
          error_message: sms_response.error_message,
          sent_at: Time.current
        )

        message
    end

    def handle_error(error_code, error)
      SendMessageResponse.new(
        success: false,
        error_code: error_code,
        error_message: error.message,
        backtrace: error.backtrace
      )
    end
  end

  class SendMessageResponse < Struct.new(:success, :message, :error_code, :error_message, :sms_response, :backtrace)
  end
end
