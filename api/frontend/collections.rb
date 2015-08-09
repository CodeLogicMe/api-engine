require 'grape'
require_relative 'auth_helpers'

module Frontend
  class Collections < Grape::API
    resource :collections do
      helpers AuthHelpers

      before { authenticate! }

      helpers do
        def api
          @api ||= current_client.apis
            .find(params.collection.api)
        end
      end

      get do
        api = client_apis.find_by(system_name: id)
        { collections: api.collections.to_h }
      end

      get ':id' do
        collection = current_client.collections.find(params.id)
        {
          collections: Serializers::Collections.new([collection]).to_h.first,
          fields: Serializers::Fields.new(collection.fields).to_h
        }
      end

      post do
        collection = api.collections
          .build(name: params.collection.name)

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
  end
end
