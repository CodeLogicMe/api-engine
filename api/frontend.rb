require 'grape'
require 'rack/cors'

require_rel '../business/setup'
require_rel './serializers'

class Frontend < ::Grape::API
  format :json
  content_type :json, 'application/json'

  helpers do
    def current_client
      return nil if headers['Authorization'].nil?

      @current_client ||=
        begin
          client_id = Services::AuthToken.retrieve(headers['Authorization'])
          Models::Client.find client_id
        end
    end

    def current_client=(client)
      @current_client = client
    end

    def authenticate!
      error!('401 Unauthorized', 401) unless current_client
    end

    def client_apps
      current_client.apps
    end
  end

  post :login do
    if client = Models::Client.authenticate(params)
      token = Services::AuthToken.generate(client)
      current_client = client
      { token: token }
    else
      status 400
    end
  end

  resource 'apps' do
    before { authenticate! }

    get do
      {
        apps: Serializers::Apps.new(client_apps).to_h
      }
    end

    get '/:app_id' do
      app = client_apps.find_by(system_name: params.app_id)
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
        @ids ||= params.fetch(:id) { params.entity.app }.split('#')
      end

      def app
        @app ||= client_apps.find_by(system_name: ids[0])
      end

      def entity_repository
        @entity_repo ||= Repositories::Entities
          .new(app: app)
      end
    end

    get do
      app = client_apps.find_by(system_name: id)
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
      app = client_apps.find_by(system_name: params.entity.app)
      result = entity_repository.add(params.entity)

      if result.ok?
        entity = entity_repository.all.last
        entity_attrs = Serializers::Entities
          .new(app, [entity])
          .to_h[0]
        fields_attrs = Serializers::Fields
          .new(app, entity, entity['fields'])
          .to_h

        { entity: entity_attrs, fields: fields_attrs }
      else
        status(400) and { errors: result.errors }
      end
    end
  end

  resource :fields do
    helpers do
      def ids
        @ids ||= params.fetch('id') { params.field.entity }.split('#')
      end

      def app
        @app ||= client_apps.find_by system_name: ids[0]
      end

      def entity
        @entity ||= app.app_config.entity(name: ids[1])
      end

      def field_repository
        @field_repo ||= Repositories::Fields
          .new(app: app, entity: entity)
      end
    end

    post do
      result = field_repository.add(params.field)

      if result.ok?
        new_field = field_repository.all.last
        { field: Serializers::Fields.new(app, entity, [new_field]).to_h[0] }
      else
        status(400) and { errors: result.errors }
      end
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
