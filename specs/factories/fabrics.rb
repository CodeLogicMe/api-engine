FactoryGirl.define do
  factory :app, class: Authentik::Models::App do
    name { Faker::Name.name }
    password { Faker::Internet.password }
  end

  factory :user, class: Authentik::Models::User do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
