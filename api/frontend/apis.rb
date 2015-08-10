require_relative 'auth_helpers'
require_relative 'serializers/api'
require_relative 'serializers/tier'
require_relative 'serializers/collection'
require_relative 'serializers/field'

module Frontend
  class Apis < Grape::API
    resource :apis do
      helpers AuthHelpers

      before { authenticate! }

      get do
        apis = current_client.apis.includes(:private_key)
        {
          apis: apis.map { |api| Serializers::Api.new(api).to_h }
        }
      end

      get '/:api_id' do
        api = current_client.apis
          .includes(tier_usages: :tier)
          .includes(collections: :fields)
          .includes(:private_key)
          .find(params.api_id)
        {
          api: Serializers::Api.new(api).to_h,
          tiers: [Serializers::Tier.new(api.tier).to_h],
          collections: api.collections.map { |collection|
            Serializers::Collection.new(collection).to_h },
          fields: api.collections.flat_map { |collection|
              collection.all_fields.map { |field|
                Serializers::Field.new(field).to_h
              }
            }.uniq { |a| a.fetch(:id) }
        }
      end

      post do
        data = { name: params.api.name }
        api = current_client.apis.create!(data)
        { api: Serializers::Api.new(api).to_h }
      end

      put '/:api_id' do
        tier = Models::Tier.find(params.api.tier)
        api = current_client.apis.find(params.api_id)
        Actions::ChangeApiTier.new(api: api, tier: tier).call
        { api: Serializers::Api.new(api).to_h }
      end
    end
  end
end
