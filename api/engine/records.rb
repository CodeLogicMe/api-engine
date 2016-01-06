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

    rescue_from ActiveRecord::RecordNotFound do
      Rack::Response.new \
        [{ errors: ["Record not found"] }.to_json],
        404,
        { "Content-Type" => "application/json" }
    end

    resource "/:collection_name" do
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

      put "/:id" do
        record = current_repository.find(params.id)
        validations = current_repository
          .update(record, collection_params)

        if validations.ok?
          validations.result.to_h
        else
          status 400
          { errors: validations.errors }
        end
      end

      delete "/:id" do
        current_repository.delete params.fetch(:id)
      end
    end
  end
end
