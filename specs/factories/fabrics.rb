FactoryGirl.define do
  factory :client, class: Authentik::Models::Client do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end

  factory :app, class: Authentik::Models::App do
    name { Faker::Name.name }
  end

  factory :private_key, class: Authentik::Models::PrivateKey do
    app
  end

  factory :user, class: Authentik::Models::User do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
