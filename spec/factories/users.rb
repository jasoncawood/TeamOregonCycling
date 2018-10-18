FactoryBot.define do
  sequence :user_email do |n|
    "user.#{n}@example.com"
  end

  factory :user do
    email { generate(:user_email) }
    password { 'This is my passw3rd!' }
    first_name { 'Justa' }
    last_name { 'Notheruser' }
  end
end
