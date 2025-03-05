json.array! @messages do |message|
  @message = message
  json.partial! "messages/message", message: message
end
