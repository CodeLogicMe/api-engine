require 'grape'
require 'rack/cors'

require_rel '../business/setup'

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
        apps: Models::Client.first.apps.map { |app| app_attrs(app) }
      }
    end

    get '/:app_id' do
      app = Models::Client.first.apps.find_by(system_name: params.app_id)
      {
        app: app_attrs(app),
        entities: app.app_config.entities.map { |entity| entity_attrs(app, entity) },
        fields: app.app_config.entities.flat_map { |entity| fields_attrs(app, entity) }
      }
    end
  end

  resource :entities do
    get ':id' do
      ids = params.id.split('#')
      app = Models::Client.first.apps.find_by(system_name: ids[0])
      entity = app.app_config.entities.find { |entity| entity['name'] == ids[1] }
      {
        entity: entity_attrs(app, entity),
        fields: fields_attrs(app, entity)
      }
    end

    post do
      p params
      app = Models::Client.first.apps.find_by(system_name: params.entity.app)
      Actions::AddEntity
        .new(params['entity'])
        .call(app)
      {}
    end
  end

  resource :fields do
    put ':id' do
      ids = params.id.split('#')
      app = Models::Client.first.apps.find_by system_name: ids[0]
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

def fields_attrs(app, entity)
  entity[:fields].map do |field|
    {
      id: field_id(app, entity, field),
      name: field[:name],
      type: field[:type],
      validates: Array(field[:validates]),
      internal: field[:internal],
      entity: "#{app.system_name}##{entity[:name]}"
    }
  end
end

def field_id(app, entity, field)
  "#{app.system_name}##{entity[:name]}##{field[:name]}"
end

def app_attrs(app)
  {
    id: app.system_name,
    name: app.name,
    public_key: app.public_key,
    private_key: app.private_key.secret,
    entities: app.app_config.entities.map { |entity| "#{app.system_name}##{entity[:name]}" }
  }
end

def entity_attrs(app, entity)
  {
    id: "#{app.system_name}##{entity[:name]}",
    name: entity[:name],
    fields: entity[:fields].map { |field| field_id(app, entity, field) }
  }
end
