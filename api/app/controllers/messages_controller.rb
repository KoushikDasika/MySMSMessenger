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
end
