FactoryBot.define do
  factory :message do
    body { Faker::Lorem.sentence }
    sender { create(:user) }
    recipient { create(:user) }
  end
end
