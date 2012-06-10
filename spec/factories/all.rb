# Read about factories at http://github.com/thoughtbot/factory_girl
require 'factory_girl/syntax/blueprint'

FactoryGirl.define do
  sequence :email do |n|
    "#{n}-#{Faker::Internet.email}"
  end

  factory :user do
    username Faker::Internet.user_name
    email
    password 'admin'
    password_confirmation { password }

    factory :admin do
      username "admin"
      admin true
      confirmed_at Time.now
    end
  end

  factory :account do
    user
    from Faker::Internet.email
    name Faker::Name.name
    test_recipient_emails %w(test@test.de test2@test.de)

    factory :biff_account do
    end
  end

  factory :recipient do
    account
    email
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    state 'confirmed'

   # factory :josh, :class => :recipient do
   #   association :biff_account
   # end
   #
   # factory :wonne, :class => :recipient do
   #   account #biff
   # end
   #
   # factory :raziel, :class => :recipient do
   #   account #biff
   #   state 'pending'
   # end
   #
   # factory :admin_r, :class => :recipient do
   #   account #admin
   # end
  end

  factory :newsletter do
    account

    subject Faker::Lorem.words
  end

  factory :bounce do
    raw File.read(Rails.root.join('spec', 'fixtures', 'mail.txt').to_s)
  end

  factory :live_send_out do |me|
    state 'finished'
    recipient
    #both share same account
    newsletter { FactoryGirl.create(:newsletter, :account => recipient.account) }
  end

  factory :asset do
    account
    user { account.user }

    factory :asset2 do
      attachment_file_name "picture_two.jpg"
    end

    factory :asset3 do
      attachment_file_name "picture_three.jpg"
    end

  end
end
