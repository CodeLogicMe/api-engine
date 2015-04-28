require 'grape'
require 'rack/cors'
require_rel '../business/models'

class Frontend < ::Grape::API
  format :json
  content_type :json, 'application/json'

  use ::Rack::Cors do
    allow do
      origins '*'
      resource '*',
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
            fields: entity[:fields].map { |field| field_id(app, entity, field) }
          }
        },
        fields: app.app_config.entities.flat_map { |entity| fields(app, entity) }
      }
    end
  end

  resource :fields do
    put ':id' do
      ids = params.id.split('#')
      app = Models::Client.first.apps.find_by(system_name: ids[0])
      entity = app.app_config.entities.find do |entity|
        entity['name'] == ids[1]
      end
      entity['fields'].delete_if do |field|
        field['name'] == ids[2]
      end

      params.field.delete('entity')
      entity['fields'] << params.field.to_h

      app.app_config.save!

      {}
    end
  end
end

def fields(app, entity)
  entity[:fields].map do |field|
    {
      id: field_id(app, entity, field),
      name: field[:name],
      type: field[:type],
      validates: Array(field[:validates]),
      internal: field[:internal],
      entity: entity[:name]
    }
  end
end

def field_id(app, entity, field)
  "#{app.system_name}##{entity[:name]}##{field[:name]}"
end

def app_fields
  lambda { |app|
    { id: app.system_name, name: app.name }
  }
end
