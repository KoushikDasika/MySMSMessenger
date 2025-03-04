module Messages
  class SendMessage
    def initialize(to:, from:, body:)
      @to = to
      @from = from
      @body = body
    end

    def call
      recipient = User.find_or_create_by(phone_number: @to)
      sender = User.find_or_create_by(phone_number: @from)

      message = Message.create!(
        to: @to,
        from: @from,
        body: @body,
        success: false,
        recipient: recipient,
        sender: sender
      )

      SendMessageResponse.new(
        success: true,
        message: message,
        error_code: nil,
        error_message: nil
      )
    rescue Mongoid::Errors::Validations => e
      SendMessageResponse.new(
        success: false,
        message: nil,
        error_code: "validation_error",
        error_message: e.message
      )
    rescue StandardError => e
      SendMessageResponse.new(
        success: false,
        message: nil,
        error_code: nil,
        error_message: e.message
      )
    end
  end

  class SendMessageResponse < Data.define(:success, :message, :error_code, :error_message)
  end
end
