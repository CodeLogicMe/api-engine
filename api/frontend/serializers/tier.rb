module Serializers
  class Tier
    def initialize(tier)
      @tier = tier
    end

    def to_h
      {
        id: @tier.to_param,
        name: @tier.name,
        quota: @tier.quota,
        price: @tier.price
      }
    end
  end
end
