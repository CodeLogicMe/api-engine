require 'grape'
require_relative 'auth_helpers'

module Frontend
  class Fields < Grape::API
    resource :fields do
      helpers AuthHelpers

      before { authenticate! }

      helpers do
        def api
          @api ||= current_client.apis.find(params.api)
        end

        def collection
          # TODO: find a way to submit the api id from ember
          @collection ||= current_client.collections
            .find(params.field.collection)
        end

        def field
          @field ||= collection.fields.find(params.id)
        end
      end

      post do
        field = collection.fields.build \
          name: params.field.name,
          type: params.field.type,
          validations: params.field.validations

        if field.save
          { field: Serializers::Fields.new(field).to_h[0] }
        else
          status(400) and { errors: field.errors.full_messages }
        end
      end

      put ':id' do
        field.update_attributes \
          name: params.field.name,
          type: params.field.type,
          validations: params.field.validations

        if field.save
          { field: Serializers::Fields.new(field).to_h.first }
        else
          status(400) and { errors: field.errors.full_messages }
        end
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
