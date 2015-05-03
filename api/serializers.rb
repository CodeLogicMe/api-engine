module Serializers
  class Apps
    def initialize(apps)
      @apps = Array(apps)
    end

    def to_h
      @apps.map do |app|
        {
          id: app.system_name,
          name: app.name,
          public_key: app.public_key,
          private_key: app.private_key.secret,
          entities: app.app_config.entities.map do |entity|
            Entities.idify(app, entity)
          end
        }
      end
    end
  end

  class Entities
    def initialize(app, collection)
      @app = app
      @entities = Array(collection)
    end

    def self.idify(app, entity)
      "#{app.system_name}##{entity[:name]}"
    end

    def to_h
      @entities.map do |entity|
        {
          id: self.class.idify(@app, entity),
          name: entity[:name],
          fields: entity[:fields].map { |field| Fields.idify(@app, entity, field) }
        }
      end
    end
  end

  class Fields
    def initialize(app, entity, fields)
      @app = app
      @entity = entity
      @fields = Array(fields)
    end

    def self.idify(app, entity, field)
      "#{app.system_name}##{entity[:name]}##{field[:name]}"
    end

    def to_h
      @fields.map do |field|
        {
          id: self.class.idify(@app, @entity, field),
          name: field[:name],
          type: field[:type],
          validates: Array(field[:validates]),
          internal: field[:internal],
          entity: Entities.idify(@app, @entity)
        }
      end
    end
  end
end
