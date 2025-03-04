class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body, type: String
  field :success, type: Boolean
  field :sent_at, type: DateTime
  field :message_sid, type: String
  field :error, type: String
  field :from, type: String
  field :to, type: String

  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
end
