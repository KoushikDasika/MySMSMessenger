class MessagesController < ApplicationController
  def index
    if current_user.nil?
      @messages = []
    else
      @messages = current_user.sent_messages.order(created_at: :asc)
    end

    render :index, status: :ok
  end

  def create
    service_response = Messages::SendMessage.new(
      to: message_params[:to],
      from: current_user.phone_number,
      body: message_params[:body]
    ).call

    if service_response.success
      @message = service_response.message
      render :show, status: :created
    else
      render json: {
        error: service_response.error_message,
        code: service_response.error_code,
      }, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:to, :body)
  end

  def session_id
    cookies[:session_id] ||= SecureRandom.uuid
  end

  def current_user
    if cookies[:session_id].nil?
      # hardcoding the phone number for testing/dev purposes
      # In the real world, you'd use the phone number from the user's profile
      # or throw an error if no phone number is found
      User.find_or_create_for_session(
        phone_number: Rails.application.credentials.twilio[:phone_number],
        session_id: session_id
      )
    else
      User.where(session_id: session_id).first
    end
  end
end
