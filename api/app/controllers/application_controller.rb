class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

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
