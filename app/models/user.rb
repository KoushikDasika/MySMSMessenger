class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :phone_number, type: String
  field :session_id, type: String

  index({ phone_number: 1 }, { unique: true })

  validates :phone_number, presence: true, uniqueness: true
  
  has_many :sent_messages, class_name: Message, inverse_of: :sender_id
  has_many :received_messages, class_name: Message, inverse_of: :recipient_id

  def self.find_or_create_for_session(phone_number:, session_id:)
    user = User.find_or_create_by(phone_number: phone_number)
    user.add_session_id(session_id)
    user
  end

  def add_session_id(session_id)
    return if self.session_id == session_id
    self.update_attribute(:session_id, session_id)
  end
end
