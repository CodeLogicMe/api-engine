require 'grape'

require_relative 'janus/all'
require_relative 'terminus/middleware'
require_relative 'veritas/middleware'
require_relative 'hermes/all'

module Engine
  class Records < Grape::API
    if ENV['RACK_ENV'] != 'test'
      use Veritas::Middleware
    end
    use Janus::Middleware
    use Terminus::Middleware
    use Hermes::Middleware

    helpers Janus::Helpers
    helpers Hermes::Helpers

    resource '/:collection_name' do
      get do
        {
          count: current_repository.count,
          items: current_repository.all.map(&:to_h)
        }
      end

      post do
        validations = current_repository
          .create(collection_params)

        if validations.ok?
          validations.result.to_h
        else
          status 400
          { errors: validations.errors }
        end
      end

      put '/:id' do
        begin
          record = current_repository.find(params.id)
          validations = current_repository
            .update(record, collection_params)

          if validations.ok?
            validations.result.to_h
          else
            status 400
            { errors: validations.errors }
          end
        rescue ActiveRecord::RecordNotFound
          status 404
          { errors: ['Record not found'] }
        end
      end

      delete '/:id' do
        begin
          current_repository.delete params.fetch(:id)
          status 204
        rescue ActiveRecord::RecordNotFound
          status 404
          { errors: ['Record not found'] }
        end
      end
    end
  end
end