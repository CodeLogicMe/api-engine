module Models
  FactoryGirl.define do
    factory :client, class: Client do
      email { Faker::Internet.email }
      password { Faker::Internet.password }
    end

    factory :app, class: App do
      client
      name { Faker::Company.name }

      trait :with_config do
        after(:create) do |app|
          create :app_config, app: app
        end
      end
    end

    factory :app_config, class: AppConfig do
      entities {
        [{
          name: "podcasts",
          fields: [
            { name: 'id', type: 'text' },
            { name: 'name', type: 'text', validates: ['presence'] },
            { name: 'episodes', type: 'number', validates: ['presence'] },
            { name: 'created_at', type: 'datetime' },
            { name: 'updated_at', type: 'datetime' }
          ]
        }]
      }
    end

    factory :private_key, class: PrivateKey do
      app
    end
  end
end
