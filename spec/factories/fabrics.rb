module Models
  FactoryGirl.define do
    factory :client, class: Client do
      email { Faker::Internet.email }
      # password { Faker::Internet.password }
      password "12345"
    end

    factory :api, class: Api do
      client
      sequence :name do |n|
        Faker::App.name + n.to_s
      end

      trait :podcast do
        after(:create) do |api|
          create(:collection, :podcast, api: api)
        end
      end
    end

    factory :private_key, class: PrivateKey do
      api
    end

    factory :tier_usage, class: TierUsage do
      api
      tier
    end

    factory :tier, class: Tier do
      sequence(:name) { |i| "small api - #{i}" }
      quota 100_000
      price 100

      trait :free do
        name 'free'
        quota 500
        price 0
      end

      trait :prototype do
        name 'prototype'
        quota 1000
      end
    end

    factory :collection, class: Collection do
      api
      name { Faker::Lorem.word }

      trait :podcast do
        name 'podcasts'
        after(:build) do |c|
          create(:field, :name, collection: c)
          create(:field, :website, collection: c)
          create(:field, :episodes, collection: c)
        end
      end
    end

    factory :field, class: Field do
      collection
      name { Faker::Hacker.noun }
      type 'text'
      validations []

      trait :name do
        name 'name'
        type 'text'
        validations ['presence', 'uniqueness']
      end

      trait :website do
        name 'website'
        type 'text'
        validations ['presence', 'uniqueness']
      end

      trait :episodes do
        name 'episodes'
        type 'number'
        validations ['presence']
      end
    end

    factory :record, class: Record do
      api { collection.api }
      collection
    end
  end
end
