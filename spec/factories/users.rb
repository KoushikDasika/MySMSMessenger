FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    email { Faker::Internet.email }
  end
end
