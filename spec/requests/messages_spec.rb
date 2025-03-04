require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  let(:session_id) { SecureRandom.uuid }
  let(:twilio_number) { Faker::PhoneNumber.cell_phone_in_e164 }
  let(:recipient_number) { Faker::PhoneNumber.cell_phone_in_e164 }

  before do
    allow(Rails.application.credentials).to receive(:twilio)
      .and_return({ phone_number: twilio_number })
  end

  describe 'GET /messages' do
    before do
      # Set session cookie
      cookies[:session_id] = session_id

      recipient = FactoryBot.create(:user, phone_number: recipient_number)
      sender = FactoryBot.create(:user, session_id: session_id, phone_number: twilio_number)

      # Create messages for this session
      message1 = FactoryBot.create(:message,
        from: sender.phone_number,
        to: recipient.phone_number,
        body: 'Hello!',
        sender: sender,
        recipient: recipient
      )
      message2 = FactoryBot.create(:message,
        from: recipient.phone_number,
        to: sender.phone_number,
        body: 'Hi there!',
        sender: sender,
        recipient: recipient
      )
      # Create message for different session (shouldn't be returned)
      message3 = FactoryBot.create(:message,
        from: sender.phone_number,
        to: recipient.phone_number,
        body: 'Different session',
        sender: sender,
        recipient: recipient
      )
    end

    it 'returns messages for the current session' do
      get '/messages'

      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.first).to include(
        'body' => 'Hi there!',
        'session_id' => session_id
      )
    end

    it 'creates new session_id if none exists' do
      cookies.delete(:session_id)

      get '/messages'

      expect(cookies.signed[:session_id]).to be_present
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to be_empty
    end

    it 'orders messages by created_at desc' do
      get '/messages'

      json_response = JSON.parse(response.body)
      created_ats = json_response.map { |msg| msg['created_at'] }
      expect(created_ats).to eq(created_ats.sort.reverse)
    end
  end

  describe 'POST /messages' do
    let(:valid_params) do
      {
        message: {
          to: recipient_number,
          body: 'Hello there!',
        },
      }
    end

    let(:sms_service) { instance_double(Apis::Twilio::SendSmsService) }
    let(:sms_response) do
      instance_double(
        Apis::Twilio::SendSmsServiceResponse,
        success: true,
        message_sid: 'SM123',
        error_code: nil,
        error_message: nil
      )
    end

    before do
      cookies.signed[:session_id] = session_id
      allow(Apis::Twilio::SendSmsService).to receive(:new).and_return(sms_service)
      allow(sms_service).to receive(:call).and_return(sms_response)
    end

    it 'creates a new message with session_id' do
      expect {
        post '/messages', params: valid_params
      }.to change(Message, :count).by(1)

      expect(response).to have_http_status(:created)

      json_response = JSON.parse(response.body)
      expect(json_response).to include(
        'body' => 'Hello there!',
        'to' => recipient_number,
        'from' => twilio_number,
        'session_id' => session_id,
        'success' => true
      )
    end

    it 'creates new session_id if none exists' do
      cookies.delete(:session_id)

      post '/messages', params: valid_params

      expect(cookies.signed[:session_id]).to be_present
      expect(response).to have_http_status(:created)
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          message: {
            to: '',
            body: 'Hello there!',
          },
        }
      end

      it 'returns unprocessable entity status' do
        post '/messages', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when SMS service fails' do
      let(:failed_sms_response) do
        instance_double(
          Apis::Twilio::SendSmsServiceResponse,
          success: false,
          message_sid: nil,
          error_code: '21211',
          error_message: 'Invalid phone number'
        )
      end

      before do
        allow(sms_service).to receive(:call).and_return(failed_sms_response)
      end

      it 'returns error details' do
        post '/messages', params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          'error' => 'Invalid phone number',
          'code' => '21211'
        )
      end
    end
  end
end
