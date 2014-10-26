FactoryGirl.define do
  factory :client, class: Authk::Models::Client do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end

  factory :app, class: Authk::Models::App do
    client
    name { Faker::Name.name }
  end

  factory :private_key, class: Authk::Models::PrivateKey do
    app
  end

  factory :user, class: Authk::Models::User do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
