module Serializers
  class Api
    def initialize(api)
      @api = api
    end

    def to_h
      {
        id: @api.to_param,
        name: @api.name,
        public_key: @api.public_key,
        private_key: @api.private_key.secret,
        collections: @api.collections.map(&:to_param),
        tier: @api.tier.to_param
      }
    end
  end
end
