module RestInMe
  class Resources::Endpoints < ::Grape::API
    helpers do
      def check_entity_for_current_app!
        unless current_app.has_entity?(entity_name)
          error!({ errors: ['Not Found'] }, 404)
        end
      end

      def entity_name
        params[:entity_name]
      end

      def current_repository
        @repository ||= Repository.new(current_app, entity_name)
      end

      def entity_params
        @entity_params ||= begin
          params.select { |key, value|
            current_app.has_field?(entity_name, key)
          }
        end
      end
    end

    before do
      authenticate_app!
      check_entity_for_current_app!
    end

    resource '/:entity_name' do
      get do
        {
          count: current_repository.count,
          items: current_repository.all.map(&:attributes)
        }
      end

      post do
        current_repository
          .create(entity_params)
          .attributes
      end

      delete '/:id' do
        current_repository.delete params.fetch(:id)
        status 204
      end
    end
  end
end
