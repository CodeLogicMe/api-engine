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
          return nil unless client_id
          Models::Client.find client_id
        end
    end

    def current_client=(client)
      @current_client = client
    end

    def authenticate!
      unless current_client
        error!('401 Unauthorized', 401, 'Access-Control-Allow-Origin' => '*')
      end
    end

    def client_apis
      current_client.apis
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

  resource :apis do
    before { authenticate! }

    get do
      {
        apis: Serializers::Apis.new(client_apis).to_h
      }
    end

    get '/:api_id' do
      api = client_apis.find_by(system_name: params.api_id)
      {
        api: Serializers::Apis.new(api).to_h[0],
        tiers: Serializers::Tiers.new(api.tier).to_h,
        entities: Serializers::Entities.new(api, api.api_config.entities).to_h,
        fields: api.api_config.entities.flat_map do |entity|
          Serializers::Fields.new(api, entity, entity['fields']).to_h
        end
      }
    end

    post do
      api = Actions::CreateApi.new(params).call
      { api: Serializers::Apis.new(api).to_h[0] }
    end

    put '/:api_id' do
      tier = Models::Tier.find(params.api.tier)
      api = client_apis.find_by(system_name: params.api_id)
      Actions::ChangeApiTier.new(api: api, tier: tier).call
      { api: Serializers::Apis.new(api).to_h[0] }
    end
  end

  resource :collections do
    before { authenticate! }

    helpers do
      def api
        @api ||= client_apis.find(params.api_id)
      end
    end

    get do
      api = client_apis.find_by(system_name: id)
      { collections: api.collections.to_h }
    end

    get ':id' do
      entity = api.api_config.entities.find { |entity| entity['name'] == ids[1] }
      {
        entity: Serializers::Entities.new(api, [entity]).to_h[0],
        fields: api.api_config.entities.flat_map do |entity|
          Serializers::Fields.new(api, entity, entity['fields']).to_h
        end
      }
    end

    post do
      collection = api.collections.build(params.collection)

      if collection.save
        collection_attrs = Serializers::Collections
          .new(collection).to_h[0]
        fields_attrs = Serializers::Fields
          .new(collection.fields).to_h

        {
          collection: collection_attrs,
          fields: fields_attrs
        }
      else
        status(400) and { errors: collection.errors.full_messages }
      end
    end
  end

  resource :fields do
    before { authenticate! }

    helpers do
      def api
        @api ||= client_apis.find(params.api_id)
      end

      def collection
        @collection ||= api
          .collection(params.field.collection_id)
      end
    end

    post do
      field = collection.fields.build params.field

      if field.save
        { field: Serializers::Fields.new(field).to_h[0] }
      else
        status(400) and { errors: field.errors.full_messages }
      end
    end

    put ':id' do
      entity['fields'].delete_if do |field|
        field['name'] == ids[2]
      end

      params.field.delete('entity')
      entity['fields'] << params.field.to_h

      api.api_config.save!

      {}
    end

    delete ':id' do
      entity['fields'].delete_if do |field|
        field['name'] == ids[2]
      end

      api.api_config.save!

      {}
    end
  end

  resource :tiers do
    before { authenticate! }

    get do
      tiers = Models::Tier.order_by(:quota.asc)
      { tiers: Serializers::Tiers.new(tiers).to_h }
    end

    get ':id' do
      tier = Models::Tier.find(params.id)
      { tier: Serializers::Tiers.new(tier).to_h }
    end
  end

  get '/statistics/:api_id' do
    authenticate!
    api = client_apis.find_by(system_name: params.api_id)
    { statistic: Serializers::Stats.new(api).to_h }
  end
end
