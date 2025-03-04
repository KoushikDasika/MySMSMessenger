class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body, type: String
  field :successfully_sent_at, type: DateTime

  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
end
