module RestInMe::Models
  ::FactoryGirl.define do
    factory :client, class: Client do
      email { ::Faker::Internet.email }
      password { ::Faker::Internet.password }
    end

    factory :app, class: App do
      client
      name { ::Faker::Company.name }
    end

    factory :app_config, class: AppConfig do
      app
      entities {
        [{
          name: 'podcast',
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

    factory :user, class: User do
      email { ::Faker::Internet.email }
      password { ::Faker::Internet.password }

      factory :user_with_loose_data do
        loose_data LooseData.new(
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
end
