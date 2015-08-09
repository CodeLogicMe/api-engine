require 'grape'
require_relative 'janus/middleware'
require_relative 'terminus/middleware'
require_relative 'veritas/middleware'
require_relative 'hermes/middleware'

module Engine
  class Collection < Grape::API
    if ENV['RACK_ENV'] != 'test'
      use Veritas::Middleware
    end
    use Janus::Middleware
    use Terminus::Middleware
    use Hermes::Middleware

    helpers do
      def current_api
        env.fetch('current_api')
      end

      def collection_name
        params[:collection_name]
      end

      def collection
        @collection ||= current_api.collections
          .find_by!(system_name: collection_name)
      end

      def current_repository
        ::Repository.new(collection)
      end

      def collection_params
        (params.data || {}).select do |key, value|
          collection.has_field?(key)
        end
      end
    end

    resource '/:collection_name' do
      get do
        {
          count: current_repository.count,
          items: current_repository.all.map(&:to_h)
        }
      end

      post do
        validations = current_repository.create(collection_params)
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
          validations = current_repository.update record, collection_params

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
        current_repository.delete params.fetch(:id)
        status 204
      end
    end
  end
end
