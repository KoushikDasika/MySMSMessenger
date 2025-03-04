module Messages
  class SendMessage
    attr_accessor :to, :from, :body, :sms_response

    def initialize(to:, from:, body:)
      @to = to
      @from = from
      @body = body
    end

    def call
      create_message_with_users
      @sms_response = send_sms

      SendMessageResponse.new(
        success: true,
        message: @message,
        error_code: nil,
        error_message: nil,
        sms_response: @sms_response
      )
    rescue Mongoid::Errors::Validations => e
      handle_error("validation_error", e.message)
    rescue StandardError => e
      handle_error(nil, e.message)
    end

    private

    def create_message_with_users
      recipient = find_or_create_user(@to)
      sender = find_or_create_user(@from)

      @message = Message.create!(
        to: @to,
        from: @from,
        body: @body,
        success: false,
        recipient: recipient,
        sender: sender
      )
    end

    def find_or_create_user(phone_number)
      User.find_or_create_by(phone_number: phone_number)
    end

    def send_sms
      Apis::Twilio::SendSmsService.new(
        to: @to,
        from: @from,
        body: @body
      ).call
    end

    def handle_error(error_code, error_message)
      SendMessageResponse.new(
        success: false,
        message: nil,
        error_code: error_code,
        error_message: error_message,
        sms_response: nil
      )
    end
  end

  class SendMessageResponse < Data.define(:success, :message, :error_code, :error_message, :sms_response)
  end
end
