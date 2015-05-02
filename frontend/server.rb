require 'grape'
require 'rack/cors'

require_rel '../business/setup'
require_rel './serializers'

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

  post :login do
    p params
    { token: 'a-random-auth-token' }
  end

  resource 'apps' do
    apps = Models::Client.first.apps
    get do
      {
        apps: Serializers::Apps.new(apps).to_h
      }
    end

    get '/:app_id' do
      app = Models::Client.first.apps.find_by(system_name: params.app_id)
      {
        app: Serializers::Apps.new(app).to_h[0],
        entities: Serializers::Entities.new(app, app.app_config.entities).to_h,
        fields: app.app_config.entities.flat_map do |entity|
          Serializers::Fields.new(app, entity, entity['fields']).to_h
        end
      }
    end

    post do
      app = Actions::CreateApp.new(params['app']).call do |app|
        erb :new_app, layout: :application
        return
      end
    end
  end

  resource :entities do
    helpers do
      def ids
        @ids ||= params.id.split('#')
      end

      def app
        @app ||= Models::Client.first.apps.find_by(system_name: ids[0])
      end
    end

    get do
      p params
      app = Models::Client.first.apps.find_by(system_name: id)
      app.app_config.entities.map { |entity| entity_attrs(app, entity) }
    end

    get ':id' do
      entity = app.app_config.entities.find { |entity| entity['name'] == ids[1] }
      {
        entity: Serializers::Entities.new(app, [entity]).to_h[0],
        fields: app.app_config.entities.flat_map do |entity|
          Serializers::Fields.new(app, entity, entity['fields']).to_h
        end
      }
    end

    post do
      app = Models::Client.first.apps.find_by(system_name: params.entity.app)
      Actions::AddEntity
        .new(params['entity'])
        .call(app)
      {}
    end
  end

  resource :fields do
    helpers do
      def ids
        @ids ||= params.fetch('id') { params.field.entity }.split('#')
      end

      def app
        @app ||= Models::Client.first.apps.find_by system_name: ids[0]
      end

      def entity
        @entity ||= app.app_config.entities.find do |entity|
          entity['name'] == ids[1]
        end
      end
    end

    post do
      entity['fields'] << params.field.to_h

      app.app_config.save!

      {}
    end

    put ':id' do
      entity['fields'].delete_if do |field|
        field['name'] == ids[2]
      end

      params.field.delete('entity')
      entity['fields'] << params.field.to_h

      app.app_config.save!

      {}
    end

    delete ':id' do
      entity['fields'].delete_if do |field|
        field['name'] == ids[2]
      end

      app.app_config.save!

      {}
    end
  end
end
