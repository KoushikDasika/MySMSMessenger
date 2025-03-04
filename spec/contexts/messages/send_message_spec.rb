require 'rails_helper'

RSpec.describe Messages::SendMessage do
  let(:to_number) { Faker::PhoneNumber.cell_phone_in_e164 }
  let(:from_number) { Faker::PhoneNumber.cell_phone_in_e164 }
  let(:message_body) { 'Test message' }

  describe '#call' do
    context 'when creating message record with users' do
      it 'creates new users if they do not exist' do
        service = Messages::SendMessage.new(
          to: to_number,
          from: from_number,
          body: message_body
        )

        expect {
          service.call
        }.to change { User.count }.by(2)

        recipient = User.find_by(phone_number: to_number)
        sender = User.find_by(phone_number: from_number)

        expect(recipient).to be_present
        expect(sender).to be_present
      end

      it 'reuses existing users if they exist' do
        # Create users before the test
        recipient = User.create!(phone_number: to_number)
        sender = User.create!(phone_number: from_number)

        service = Messages::SendMessage.new(
          to: to_number,
          from: from_number,
          body: message_body
        )

        expect {
          service.call
        }.not_to change(User, :count)

        message = Message.last
        expect(message.recipient).to eq(recipient)
        expect(message.sender).to eq(sender)
      end

      it 'creates a message with associated users' do
        service = Messages::SendMessage.new(
          to: to_number,
          from: from_number,
          body: message_body
        )

        expect {
          service.call
        }.to change(Message, :count).by(1)

        message = Message.last
        expect(message.attributes).to include(
          'to' => to_number,
          'from' => from_number,
          'body' => message_body,
          'success' => false
        )
        expect(message.recipient.phone_number).to eq(to_number)
        expect(message.sender.phone_number).to eq(from_number)
      end
    end

    context 'when sending SMS' do
      it 'calls Twilio service with correct parameters' do
        sms_service = instance_double(Apis::Twilio::SendSmsService)
        sms_response =
          Apis::Twilio::SendSmsServiceResponse.new(
            success: true,
            message_sid: 'SM123',
            error_code: nil,
            error_message: nil,
            full_error_message: nil
          )

        allow(Apis::Twilio::SendSmsService).to receive(:new)
          .with(to: to_number, from: from_number, body: message_body)
          .and_return(sms_service)
        allow(sms_service).to receive(:call).and_return(sms_response)

        service = Messages::SendMessage.new(
          to: to_number,
          from: from_number,
          body: message_body
        )

        result = service.call

        expect(sms_service).to have_received(:call)
        expect(result.sms_response).to eq(sms_response)
      end
    end

    context 'when updating message with SMS result' do
      it 'updates message with successful SMS response' do
        sms_service = instance_double(Apis::Twilio::SendSmsService)
        sms_response = instance_double(
          Apis::Twilio::SendSmsServiceResponse,
          success: true,
          message_sid: 'SM123',
          error_code: nil,
          error_message: nil
        )

        allow(Apis::Twilio::SendSmsService).to receive(:new)
          .with(to: to_number, from: from_number, body: message_body)
          .and_return(sms_service)
        allow(sms_service).to receive(:call).and_return(sms_response)

        service = Messages::SendMessage.new(
          to: to_number,
          from: from_number,
          body: message_body
        )

        result = service.call
        message = result.message

        expect(message.attributes).to include(
          'success' => true,
          'message_sid' => 'SM123',
          "body" => "Test message",
          'error_message' => nil
        )
        expect(message.sent_at).to be_present
      end

      it 'updates message with failed SMS response' do
        sms_service = instance_double(Apis::Twilio::SendSmsService)
        sms_response = instance_double(
          Apis::Twilio::SendSmsServiceResponse,
          success: false,
          message_sid: nil,
          error_code: '21211',
          error_message: 'Invalid phone number'
        )

        allow(Apis::Twilio::SendSmsService).to receive(:new)
          .with(to: to_number, from: from_number, body: message_body)
          .and_return(sms_service)
        allow(sms_service).to receive(:call).and_return(sms_response)

        service = Messages::SendMessage.new(
          to: to_number,
          from: from_number,
          body: message_body
        )

        result = service.call
        message = result.message

        expect(message.attributes).to include(
          'success' => false,
          'message_sid' => nil,
          'error_message' => 'Invalid phone number'
        )
        expect(message.sent_at).to be_present
      end
    end
  end

  describe 'parameter validation' do
    it 'raises error when "to" parameter is missing' do
      expect {
        Messages::SendMessage.new(
          from: from_number,
          body: message_body
        )
      }.to raise_error(ArgumentError)
    end

    it 'raises error when "from" parameter is missing' do
      expect {
        Messages::SendMessage.new(
          to: to_number,
          body: message_body
        )
      }.to raise_error(ArgumentError)
    end

    it 'raises error when "body" parameter is missing' do
      expect {
        Messages::SendMessage.new(
          to: to_number,
          from: from_number
        )
      }.to raise_error(ArgumentError)
    end
  end
end
