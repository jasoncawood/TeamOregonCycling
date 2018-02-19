FactoryBot.define do
  sequence :m_type_name do |n|
    "Membership Type #{n}"
  end

  factory :membership_type do
    name { generate(:m_type_name) }
    description 'This is one type of membership that can be purchased.'
    weight 1
    price 12.34
  end
end
