FactoryBot.define do
  factory :membership do
    association :user, factory: :user
    starts_on Date.civil(2018, 1, 1)
    ends_on Date.civil(2018, 12, 31)
  end
end
