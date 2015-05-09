module Models
  FactoryGirl.define do
    factory :client, class: Client do
      email { Faker::Internet.email }
      password { Faker::Internet.password }
    end

    factory :app, class: App do
      client
      name { Faker::Company.name }

      after(:create) do |app|
        app.tier = create(:tier, :prototype)
        app.save!
      end
      trait :with_config do
        after(:create) do |app|
          create :app_config, app: app
        end
      end
    end

    factory :tier, class: Tier do
      name 'small app'
      recurrency 'monthly'
      quota 100_000

      trait :prototype do
        name 'prototype'
        quota 1000
      end
    end

    factory :app_config, class: AppConfig do
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
      app
    end
  end
end
