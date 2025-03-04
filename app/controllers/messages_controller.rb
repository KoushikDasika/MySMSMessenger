class MessagesController < ApplicationController
  def index
    messages = current_user.sent_messages.order(created_at: :desc)

    render json: messages
  end

  def create
    service_response = Messages::SendMessage.new(
      to: message_params[:to],
      from: Rails.application.credentials.twilio[:phone_number],
      body: message_params[:body],
      session_id: session_id
    ).call

    if service_response.success
      render json: service_response.message, status: :created
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
    User.find_by(session_id: session_id)
  end
end
