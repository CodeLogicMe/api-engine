require 'grape'
require_relative 'auth_helpers'

module Frontend
  class Tiers < Grape::API
    resource :tiers do
      helpers AuthHelpers

      before { authenticate! }

      get do
        tiers = Models::Tier.order_by(quota: :asc)
        { tiers: Serializers::Tiers.new(tiers).to_h }
      end

      get ':id' do
        tier = Models::Tier.find(params.id)
        { tier: Serializers::Tiers.new(tier).to_h }
      end
    end
  end
end
