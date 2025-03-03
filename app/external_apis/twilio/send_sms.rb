class Twilio::SendSms
  def initialize(from, to, message)
    @from = from
    @to = to
    @message = message
  end

  def self.send_sms
    client = Twilio::REST::Client.new(
      Rails.application.credentials.twilio[:account_sid],
      Rails.application.credentials.twilio[:auth_token]
    )

    output = client.messages.create(
      from: "+15005550006",
      to: "+18777804236",
      body: "Hello, this is a test message"
    )

    #https://www.twilio.com/docs/iam/test-credentials#test-sms-messages-parameters-From
    puts output

  end
end
