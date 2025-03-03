class Twilio::SendSMSService
  def initialize(from:, to:, message:)
    @from = from
    @to = to
    @message = message
  end

  def send
    
    client = create_client

    output = client.messages.create(
      from: "+15005550006",
      to: "+18777804236",
      body: "Hello, this is a test message"
    )

    #https://www.twilio.com/docs/iam/test-credentials#test-sms-messages-parameters-From
    puts output
  end
  
  def create_client
    Twilio::REST::Client.new(
      Rails.application.credentials.twilio[:account_sid],
      Rails.application.credentials.twilio[:auth_token]
    )
  end
end
