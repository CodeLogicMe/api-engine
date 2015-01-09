module RestInMe
  class Resources::Endpoints < ::Grape::API
    helpers do
      def check_entity_for_current_app!
        unless current_app.has_entity?(entity_name)
          error!('Not Found', 404)
        end
      end

      def entity_name
        params[:entity_name].singularize
      end

      def current_entity
        @entity ||= begin
          entity_config = current_app.config_for(entity_name)
          Engines::EntityBuilder.new(current_app, entity_config).call
        end
      end

      def entity_params
        @entity_params ||= begin
          params.select { |key, value|
            current_app.has_field?(entity_name, key)
          }.inject({}) do |memo, (k,v)|
            memo[k.to_sym] = v; memo
          end
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
          count: current_entity.count(current_app),
          items: current_entity.all(current_app)
        }
      end

      post do
        entity = current_entity.create(
          app: current_app, **entity_params
        )
        entity.attributes.to_h
      end
    end
  end
end
