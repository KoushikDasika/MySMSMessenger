FactoryBot.define do
  factory :user do
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    session_id { SecureRandom.uuid }
  end
end
