class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :phone_number, type: String
  field :email, type: String
end
