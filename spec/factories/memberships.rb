FactoryBot.define do
  factory :membership do
    association :user, factory: :user
    association :membership_type, factory: :membership_type
    amount_paid { membership_type.price }
    starts_on Date.civil(2018, 1, 1)
    ends_on Date.civil(2018, 12, 31)
  end
end
