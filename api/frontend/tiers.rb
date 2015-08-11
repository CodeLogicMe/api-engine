require 'grape'
require_relative 'auth_helpers'

module Frontend
  class Tiers < Grape::API
    resource :tiers do
      helpers AuthHelpers

      before { authenticate! }

      get do
        tiers = Models::Tier.order(quota: :asc)
        { tiers: tiers.map { |tier|
          Serializers::Tier.new(tier).to_h }
        }
      end

      get ':id' do
        tier = Models::Tier.find(params.id)
        { tier: Serializers::Tier.new(tier).to_h }
      end
    end
  end
end
