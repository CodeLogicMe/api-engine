module Serializers
  class Apis
    def initialize(apis)
      @apis = Array(apis)
    end

    def to_h
      @apis.map do |api|
        {
          id: api.system_name,
          name: api.name,
          public_key: api.public_key,
          private_key: api.private_key.secret,
          entities: api.api_config.entities.map { |entity|
            Entities.idify(api, entity)
          },
          tier: Tiers.idify(api.tier)
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
          quota: tier.quota
        }
      end
    end
  end

  class Entities
    def initialize(api, collection)
      @api = api
      @entities = Array(collection)
    end

    def self.idify(api, entity)
      "#{api.system_name}##{entity[:name]}"
    end

    def to_h
      @entities.map do |entity|
        {
          id: self.class.idify(@api, entity),
          name: entity[:name],
          fields: entity[:fields].map { |field| Fields.idify(@api, entity, field) }
        }
      end
    end
  end

  class Fields
    def initialize(api, entity, fields)
      @api = api
      @entity = entity
      @fields = Array(fields)
    end

    def self.idify(api, entity, field)
      "#{api.system_name}##{entity[:name]}##{field[:name]}"
    end

    def to_h
      @fields.map do |field|
        {
          id: self.class.idify(@api, @entity, field),
          name: field[:name],
          type: field[:type],
          validates: Array(field[:validates]),
          internal: field[:internal],
          entity: Entities.idify(@api, @entity)
        }
      end
    end
  end
end
