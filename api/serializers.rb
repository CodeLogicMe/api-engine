module Serializers
  class Apis
    def initialize(apis)
      @apis = Array(apis)
    end

    def to_h
      @apis.map do |api|
        {
          id: api.to_param,
          name: api.name,
          public_key: api.public_key,
          private_key: api.private_key.secret,
          collections: api.collections.map(&:to_param),
          tier: api.tier.to_param
        }
      end
    end
  end

  class Stats
    def initialize(api)
      @api = api
    end

    def to_h
      {
        id: 'nevermind',
        quota: {
          current: Middlewares::Terminus.quota_for(@api),
          max: @api.tier.quota
        }
      }
    end
  end

  class Tiers
    def initialize(tiers)
      @tiers = Array(tiers)
    end

    def self.idify(tier)
      tier.id.to_s
    end

    def to_h
      @tiers.map do |tier|
        {
          id: Tiers.idify(tier),
          name: tier.name,
          quota: tier.quota,
          price: tier.price
        }
      end
    end
  end

  class Collections
    def initialize(collections)
      @collections = Array(collections)
    end

    def to_h
      @collections.map do |col|
        {
          id: col.to_param,
          name: col.name,
          fields: col.fields.map(&:id)
        }
      end
    end
  end

  class Fields
    def initialize(fields)
      @fields = Array(fields)
    end

    def to_h
      @fields.map do |field|
        {
          id: field.to_param,
          name: field.name,
          type: field.type,
          validations: field.validations,
          internal: false,
          collection: field.collection_id
        }
      end
    end
  end
end
