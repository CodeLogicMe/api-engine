module Models
  FactoryGirl.define do
    factory :client, class: Client do
      email { Faker::Internet.email }
      password { Faker::Internet.password }
    end

    factory :api, class: Api do
      client
      name { Faker::Company.name }

      trait :with_config do
        after(:create) do |api|
          create :api_config, api: api
        end
      end
    end

    factory :tier_usage, class: TierUsage do
      association :tier, factory: :tier
    end

    factory :tier, class: Tier do
      sequence(:name) { |i| "small api - #{i}" }
      quota 100_000
      price 100

      trait :prototype do
        name 'prototype'
        quota 1000
      end
    end

    factory :api_config, class: ApiConfig do
      entities {
        [{
          'name': 'podcasts',
          'fields': [
            { 'name' => 'id', 'type' => 'text', 'validates' => [] },
            { 'name' => 'name', 'type' => 'text', 'validates' => ['presence', 'uniqueness'] },
            { 'name' => 'website_url', 'type' => 'text', 'validates' => ['presence', 'uniqueness'] },
            { 'name' => 'episodes', 'type' => 'number', 'validates' => ['presence'] },
            { 'name' => 'created_at', 'type' => 'datetime', 'validates' => [] },
            { 'name' => 'updated_at', 'type' => 'datetime', 'validates' => [] }
          ]
        }]
      }
    end

    factory :private_key, class: PrivateKey do
      api
    end
  end
end
