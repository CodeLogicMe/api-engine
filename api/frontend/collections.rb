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

        def collection
          api.collections.find_by system_name: id
        end
      end

      get do
        api = colection
        { collections: api.collections.to_h }
      end

      get ':id' do
        collection = api.collections.find(params.id)

        {
          collection: Serializers::Collection.new(collection).to_h,
          fields: collection.fields.map { |field|
            Serializers::Field.new(field).to_h }
        }
      end

      post do
        collection = api.collections
          .build(name: params.collection.name)

        if collection.save
          {
            collection: Serializers::Collection.new(collection).to_h,
            fields: collection.fields.map { |field|
              Serializers::Field.new(field) }
          }
        else
          status(400) and
            { errors: collection.errors.full_messages }
        end
      end
    end
  end
end
