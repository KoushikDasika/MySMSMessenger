require 'rails_helper'

RSpec.describe Messages::SendMessage do
  let(:to_number) { Faker::PhoneNumber.cell_phone_in_e164 }
  let(:from_number) { Faker::PhoneNumber.cell_phone_in_e164 }
  let(:message_body) { 'Test message' }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    @twilio_client = Twilio::REST::Client.new
    @messages = @twilio_client.messages

    allow(Twilio::REST::Client).to receive(:new).and_return(@twilio_client)
    allow(@twilio_client).to receive(:messages).and_return(@messages)
  end

  describe '#call' do
    context 'when creating message record with session' do
      it 'creates a message with session_id' do
        sender = FactoryBot.create(:user)
        recipient = FactoryBot.create(:user)

        service = Messages::SendMessage.new(
          to: recipient.phone_number,
          from: sender.phone_number,
          body: message_body,
          session_id: session_id
        )

        response = service.call

        message = Message.find(service.message.id)

        expect(message.attributes).to include(
          'to' => recipient.phone_number,
          'from' => sender.phone_number,
          'body' => message_body,
          'success' => false
        )
      end

      it 'creates or updates user with session_id' do
        service = Messages::SendMessage.new(
          to: to_number,
          from: from_number,
          body: message_body,
          session_id: session_id
        )

        service.call

        user = User.find_by(phone_number: from_number)
        expect(user.session_id).to eq(session_id)
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
          body: message_body,
          session_id: session_id
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
          body: message_body,
          session_id: session_id
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
          body: message_body,
          session_id: session_id

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

    it 'sends an Sms with the correct parameters' do
      message_response = OpenStruct.new(
        to: to_number,
        from: from_number,
        body: message_body,
        sid: 'SM123456',
        error_code: nil,
        error_message: nil
      )
      allow(@messages).to receive(:create).and_return(message_response)

      service = Messages::SendMessage.new(
        to: to_number,
        from: from_number,
        body: message_body,
        session_id: session_id
      )

      expect(@messages).to receive(:create).with(
        to: to_number,
        from: from_number,
        body: message_body
      )

      result = service.call
      expect(result.message.attributes).to include({
        "body" => message_body,
        "from" => from_number,
        "to" => to_number,
      })
    end

    it 'returns success response when SMS is sent' do
      message_response = OpenStruct.new(
        sid: 'SM123456',
        error_code: nil,
        error_message: nil
      )
      allow(@messages).to receive(:create).and_return(message_response)

      service = Messages::SendMessage.new(
        to: to_number,
        from: from_number,
        body: message_body,
        session_id: session_id
      )

      result = service.call

      expect(result.to_h).to include(
        success: true,
        error_code: nil,
        error_message: nil
      )
      expect(result.message.attributes).to include({
        "body" => message_body,
        "from" => from_number,
        "to" => to_number,
      })
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

    it 'raises error when session_id parameter is missing' do
      expect {
        Messages::SendMessage.new(
          to: to_number,
          from: from_number,
          body: message_body
        )
      }.to raise_error(ArgumentError)
    end
  end
end
