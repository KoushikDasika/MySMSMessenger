require 'rails_helper'

RSpec.describe Twilio::SendSmsService do
  before(:each) do
    @to_number = '+15551234567'
    @from_number = '+15559876543'
    @message_body = 'Test message'

    @twilio_client = Twilio::REST::Client.new
    @messages = @twilio_client.messages

    allow(Twilio::REST::Client).to receive(:new).and_return(@twilio_client)
    allow(@twilio_client).to receive(:messages).and_return(@messages)
  end

  describe '#call' do
    it 'sends an SMS with the correct parameters' do
      message_response = OpenStruct.new(
        sid: 'SM123456',
        error_code: nil,
        error_message: nil
      )
      allow(@messages).to receive(:create).and_return(message_response)

      service = Twilio::SendSmsService.new(
        to: @to_number,
        from: @from_number,
        body: @message_body
      )

      expect(@messages).to receive(:create).with(
        to: @to_number,
        from: @from_number,
        body: @message_body
      )

      puts "here"

      result = service.call
    end

    it 'returns success response when SMS is sent' do
      message_response = OpenStruct.new(
        sid: 'SM123456',
        error_code: nil,
        error_message: nil
      )
      allow(@messages).to receive(:create).and_return(message_response)

      service = Twilio::SendSMSService.new(
        to: @to_number,
        from: @from_number,
        body: @message_body
      )

      result = service.call

      expect(result.success?).to eq(true)
      expect(result.message_sid).to eq('SM123456')
      expect(result.error_code).to be_nil
      expect(result.error_message).to be_nil
    end

    it 'returns failure response when Twilio returns an error' do
      error_response = OpenStruct.new(
        status_code: 400,
        body: { code: 21211, message: 'Invalid phone number' }.to_json
      )

      allow(@messages).to receive(:create).and_raise(
        Twilio::REST::RestError.new(
          'Error 21211',
          error_response
        )
      )

      service = Twilio::SendSMSService.new(
        to: @to_number,
        from: @from_number,
        body: @message_body
      )

      result = service.call

      expect(result.success?).to eq(false)
      expect(result.message_sid).to be_nil
      expect(result.error_code).to eq(21211)
      expect(result.error_message).to eq('Invalid phone number')
    end

    it 'returns failure response when unexpected error occurs' do
      allow(@messages).to receive(:create).and_raise(StandardError.new('Unexpected error'))

      service = Twilio::SendSMSService.new(
        to: @to_number,
        from: @from_number,
        body: @message_body
      )

      result = service.call

      expect(result.success?).to eq(false)
      expect(result.message_sid).to be_nil
      expect(result.error_code).to be_nil
      expect(result.error_message).to eq('Unexpected error')
    end
  end

  describe 'parameter validation' do
    it 'raises error when "to" parameter is missing' do
      expect {
        Twilio::SendSMSService.new(
          from: @from_number,
          body: @message_body
        )
      }.to raise_error(ArgumentError)
    end

    it 'raises error when "from" parameter is missing' do
      expect {
        Twilio::SendSMSService.new(
          to: @to_number,
          body: @message_body
        )
      }.to raise_error(ArgumentError)
    end

    it 'raises error when "body" parameter is missing' do
      expect {
        Twilio::SendSMSService.new(
          to: @to_number,
          from: @from_number
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

      service = Twilio::SendSMSService.new(
        to: @to_number,
        from: @from_number,
        body: @message_body
      )

      service.call
    end
  end
end
