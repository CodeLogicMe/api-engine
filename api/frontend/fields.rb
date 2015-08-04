require 'grape'
require_relative 'auth_helpers'

module Frontend
  class Fields < Grape::API
    resource :fields do
      helpers AuthHelpers

      before { authenticate! }

      helpers do
        def api
          @api ||= current_client.apis.find(params.api_id)
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
  end
end
