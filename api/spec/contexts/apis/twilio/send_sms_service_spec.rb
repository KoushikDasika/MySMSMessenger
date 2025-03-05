require 'rails_helper'

RSpec.describe Apis::Twilio::SendSmsService do
  let(:to_number) { '+15551234567' }
  let(:from_number) { '+15559876543' }
  let(:message_body) { 'Test message' }
  let(:twilio_client) { instance_double(Twilio::REST::Client) }
  let(:messages) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
    allow(twilio_client).to receive(:messages).and_return(messages)
  end

  describe '#call' do
    it 'sends an Sms with the correct parameters' do
      message_response = OpenStruct.new(
        to: to_number,
        from: from_number,
        body: message_body,
        sid: 'SM123456',
        error_code: nil,
        error_message: nil
      )
      allow(messages).to receive(:create).and_return(message_response)

      service = Apis::Twilio::SendSmsService.new(
        to: to_number,
        from: from_number,
        body: message_body
      )

      expect(messages).to receive(:create).with(
        to: to_number,
        from: from_number,
        body: message_body
      )

      result = service.call
    end

    it 'returns success response when SMS is sent' do
      message_response = OpenStruct.new(
        sid: 'SM123456',
        error_code: nil,
        error_message: nil
      )
      allow(messages).to receive(:create).and_return(message_response)

      service = Apis::Twilio::SendSmsService.new(
        to: to_number,
        from: from_number,
        body: message_body
      )

      result = service.call

      expect(result.to_h).to eq({
        success: true,
        message_sid: 'SM123456',
        error_code: nil,
        error_message: nil,
        full_error_message: nil,
      })
    end

    it 'returns failure response when Twilio returns an error' do
      error_response = OpenStruct.new(
        status_code: 400,
        body: {
          'code' => 21211,
          'message' => 'Invalid phone number',
          'more_info' => nil,
          'details' => nil,
        }
      )

      allow(messages).to receive(:create).and_raise(
        Twilio::REST::RestError.new(
          'Error 21211',
          error_response
        )
      )

      service = Apis::Twilio::SendSmsService.new(
        to: to_number,
        from: from_number,
        body: message_body
      )

      result = service.call

      expect(result.to_h).to eq({
        success: false,
        message_sid: nil,
        error_code: 21211,
        error_message: 'Invalid phone number',
        full_error_message: "[HTTP 400] 21211 : Error 21211\nInvalid phone number\n\n",
      })
    end

    it 'returns failure response when unexpected error occurs' do
      allow(messages).to receive(:create).and_raise(StandardError.new('Unexpected error'))

      service = Apis::Twilio::SendSmsService.new(
        to: to_number,
        from: from_number,
        body: message_body
      )

      result = service.call

      expect(result.to_h).to eq({
        success: false,
        message_sid: nil,
        error_code: nil,
        error_message: 'Unexpected error',
        full_error_message: nil,
      })
    end
  end

  describe 'parameter validation' do
    it 'raises error when "to" parameter is missing' do
      expect {
        Apis::Twilio::SendSmsService.new(
          from: from_number,
          body: message_body
        )
      }.to raise_error(ArgumentError)
    end

    it 'raises error when "from" parameter is missing' do
      expect {
        Apis::Twilio::SendSmsService.new(
          to: to_number,
          body: message_body
        )
      }.to raise_error(ArgumentError)
    end

    it 'raises error when "body" parameter is missing' do
      expect {
        Apis::Twilio::SendSmsService.new(
          to: to_number,
          from: from_number
        )
      }.to raise_error(ArgumentError)
    end
  end

  describe 'credentials' do
    it 'uses credentials from Rails configuration' do
      allow(Rails.application.credentials).to receive(:twilio)
        .and_return({ account_sid: 'test_sid', auth_token: 'test_token' })

      expect(Twilio::REST::Client).to receive(:new)
        .with('test_sid', 'test_token')

      message_response = OpenStruct.new(
        sid: 'SM123456',
        error_code: nil,
        error_message: nil
      )
      allow(messages).to receive(:create).and_return(message_response)

      service = Apis::Twilio::SendSmsService.new(
        to: to_number,
        from: from_number,
        body: message_body
      )

      service.call
    end
  end
end
