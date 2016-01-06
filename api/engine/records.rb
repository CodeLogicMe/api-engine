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
          meta: {
            page: {
              offset: params.offset || 1,
              limit: 10,
              total: current_repository.count
            }
          },
          data: current_repository.all(params.offset, 10).map(&:to_h)
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
        rescue ActiveRecord::RecordNotFound
          status 404
          { errors: ['Record not found'] }
        end
      end
    end
  end
end
