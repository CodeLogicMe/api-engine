module RestInMe::Models
  ::FactoryGirl.define do
    factory :client, class: Client do
      email { ::Faker::Internet.email }
      password { ::Faker::Internet.password }
    end

    factory :app, class: App do
      client
      name { ::Faker::Company.name }

      trait :with_config do
        after(:create) do |instance|
          create :app_config, app: instance
        end
      end
    end

    factory :app_config, class: AppConfig do
      app
      entities {
        [{
          name: 'podcasts',
          fields: [
            { name: 'name', type: 'string' },
            { name: 'episodes', type: 'integer' }
          ]
        }]
      }
    end

    factory :private_key, class: PrivateKey do
      app
    end
  end
end
