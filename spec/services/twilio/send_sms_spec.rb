require 'rails_helper'

RSpec.describe "Twilio::SendSMSService" do
  let(:to_number) { '+15551234567' }
  let(:from_number) { '+15559876543' }
  let(:message_body) { 'Test message' }
  let(:twilio_client) { instance_double(Twilio::REST::Client) }
  let(:messages_double) { double('messages') }
  let(:account_double) { double('account', messages: messages_double) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
    allow(twilio_client).to receive(:messages).and_return(messages_double)
  end

  describe '#send' do
    subject { Twilio::SendSMSService.new(to: to_number, from: from_number, body: message_body).call }

    context 'when the SMS is sent successfully' do
      let(:message_response) { double('message_response', sid: 'SM123456', error_code: nil, error_message: nil) }

      before do
        allow(messages_double).to receive(:create).and_return(message_response)
      end

      it 'sends an SMS with the correct parameters' do
        expect(messages_double).to receive(:create).with(
          to: to_number,
          from: from_number,
          body: message_body
        )
        
        subject
      end

      it 'returns a success response' do
        result = subject
        
        expect(result).to be_success
        expect(result.message_sid).to eq('SM123456')
        expect(result.error_code).to be_nil
        expect(result.error_message).to be_nil
      end
    end
  end

  describe 'with missing parameters' do
    it 'raises an error when "to" is missing' do
      expect {
        Twilio::SendSMSService.new(from: from_number, body: message_body).call
      }.to raise_error(ArgumentError, /to is required/)
    end

    it 'raises an error when "from" is missing' do
      expect {
        Twilio::SendSMSService.new(to: to_number, body: message_body).call
      }.to raise_error(ArgumentError, /from is required/)
    end

    it 'raises an error when "body" is missing' do
      expect {
        Twilio::SendSMSService.new(to: to_number, from: from_number).call
      }.to raise_error(ArgumentError, /body is required/)
    end
  end
end
