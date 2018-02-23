FactoryBot.define do
  sequence :m_type_name do |n|
    "Membership Type #{n}"
  end

  sequence(:m_type_position) { |n| n }

  factory :membership_type do
    name { generate(:m_type_name) }
    description 'This is one type of membership that can be purchased.'
    position { generate(:m_type_position) }
    price 12.34
  end
end
