module Apis
  module Twilio
    class SendSmsService
      def initialize(to:, from:, body:)
        @to = to
        @from = from
        @body = body
      end

      def call
        client = create_client

        # https://github.com/twilio/twilio-ruby/blob/main/lib/twilio-ruby/rest/api/v2010/account/message.rb#L61
        response = client.messages.create(
          from: @from,
          to: @to,
          body: @body
        )

        SendSmsServiceResponse.new(
          success: true,
          message_sid: response.sid,
        )
      rescue ::Twilio::REST::RestError => error
        SendSmsServiceResponse.new(
          success: false,
          error_code: error.code,
          error_message: error.error_message,
          full_error_message: error.backtrace
        )
      rescue StandardError => e
        SendSmsServiceResponse.new(
          success: false,
          error_message: e.message,
          full_error_message: e.backtrace
        )
      end

      private

      def create_client
        ::Twilio::REST::Client.new(
          Rails.application.credentials.twilio[:account_sid],
          Rails.application.credentials.twilio[:auth_token]
        )
      end
    end

    class SendSmsServiceResponse < Struct.new(:success, :message_sid, :error_code, :error_message, :full_error_message)
    end
  end
end
