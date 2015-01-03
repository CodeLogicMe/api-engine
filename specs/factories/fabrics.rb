FactoryGirl.define do
  factory :client, class: RestInMe::Models::Client do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end

  factory :app, class: RestInMe::Models::App do
    client
    name { Faker::Name.name }
  end

  factory :private_key, class: RestInMe::Models::PrivateKey do
    app
  end

  factory :user, class: RestInMe::Models::User do
    email { Faker::Internet.email }
    password { Faker::Internet.password }

    factory :user_with_loose_data do
      loose_data RestInMe::Models::LooseData.new(
        properties: {
          previous_saber: 'yellow',
          current_saber: 'blue',
          saber_type: 'dual'
        }
      )
    end
  end

  # factory :loose_data, class: RestInMe::Models::LooseData do
  #   properties \
  # end
end
