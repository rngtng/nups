require 'machinist/active_record'

User.blueprint do
  username { Faker::Internet.user_name }
  email { Faker::Internet.email }
  password { 'admin' }
  password_confirmation { object.password }
  accounts
end

User.blueprint(:admin) do
  username { "admin" }
  admin { true }
  confirmed_at { Time.now }
end


Account.blueprint do
  user
  name { Faker::Name.name }
end


Recipient.blueprint do
  account
  email { Faker::Internet.email }
end


Newsletter.blueprint do
  account
  subject { Faker::Lorem.words }
end