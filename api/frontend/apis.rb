require_relative 'auth_helpers'
require_relative '../serializers'

module Frontend
  class Apis < Grape::API
    resource :apis do
      helpers AuthHelpers

      before { authenticate! }

      get do
        apis = current_client.apis.includes(:private_key)
        {
          apis: Serializers::Apis.new(apis).to_h
        }
      end

      get '/:api_id' do
        api = current_client.apis
          .includes(tier_usages: :tier)
          .includes(collections: :fields)
          .includes(:private_key)
          .find(params.api_id)
        {
          api: Serializers::Apis.new(api).to_h[0],
          tiers: Serializers::Tiers.new(api.tier).to_h,
          collections: Serializers::Collections.new(api.collections).to_h,
          fields: api.collections.flat_map do |collection|
            Serializers::Fields.new(collection.fields).to_h
          end
        }
      end

      post do
        data = { name: params.api.name }
        api = current_client.apis.create!(data)
        { api: Serializers::Apis.new(api).to_h[0] }
      end

      put '/:api_id' do
        tier = Models::Tier.find(params.api.tier)
        api = current_client.apis.find_by(system_name: params.api_id)
        Actions::ChangeApiTier.new(api: api, tier: tier).call
        { api: Serializers::Apis.new(api).to_h[0] }
      end
    end
  end
end
