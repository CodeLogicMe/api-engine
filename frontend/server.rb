require "grape"
require "rack/cors"
require_rel '../business/models'

class Frontend < ::Grape::API
  format :json
  content_type :json, "application/json"

  use ::Rack::Cors do
    allow do
      origins "*"
      resource "*",
        headers: :any,
        methods: %i( get post put delete options )
    end
  end

  resource 'apps' do
    get do
      {
        apps: Models::Client.first.apps.map(&app_fields)
      }
    end

    get '/:app_id' do
      app = Models::Client.first.apps.find_by(system_name: params.app_id)
      {
        app: {
          id: app.system_name,
          name: app.name,
          entities: app.app_config.entities.map { |entity| entity[:name] },
        },
        entities: app.app_config.entities.map { |entity|
          {
            id: entity[:name],
            name: entity[:name],
            fields: entity[:fields].map { |field| field_id(entity, field) }
          }
        },
        fields: app.app_config.entities.flat_map { |entity| fields(entity) }
      }
    end
  end
end

def fields(entity)
  entity[:fields].map do |field|
    {
      id: field_id(entity, field),
      name: field[:name],
      type: field[:type],
      validates: Array(field[:validates]),
      internal: field[:internal],
      entity: entity[:name]
    }
  end
end

def field_id(entity, field)
  "#{entity[:name]}##{field[:name]}"
end

def app_fields
  lambda { |app|
    { id: app.system_name, name: app.name }
  }
end
