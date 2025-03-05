json.id message.id.to_s
json.body message.body
json.from message.from
json.to message.to
json.success message.success
json.sent_at message.sent_at
json.message_sid message.message_sid
json.created_at message.created_at
json.updated_at message.updated_at

json.sender do
  json.id message.sender.id.to_s
  json.phone_number message.sender.phone_number
end

json.recipient do
  json.id message.recipient.id.to_s
  json.phone_number message.recipient.phone_number
end
