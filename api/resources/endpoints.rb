class Resources::Endpoints < Grape::API
  helpers do
    def check_entity_for_current_api!
      unless current_api.has_entity?(entity_name)
        error!({ errors: ['Not Found'] }, 404)
      end
    end

    def entity_name
      params[:entity_name]
    end

    def current_repository
      @repository ||= ::Repository.new(current_api, entity_name)
    end

    def entity_params
      @entity_params ||=
        begin
          (params.data || {}).select do |key, value|
            current_api.has_field?(entity_name, key)
          end
        end
    end
  end

  before do
    check_entity_for_current_api!
  end

  resource '/:entity_name' do
    get do
      {
        count: current_repository.count,
        items: current_repository.all.map(&:attributes)
      }
    end

    post do
      validations = current_repository.create(entity_params)
      if validations.ok?
        validations.result.attributes
      else
        status 400
        { errors: validations.errors }
      end
    end

    put '/:id' do
      begin
        record = current_repository.find(params.id)
        validations = current_repository.update record, entity_params

        if validations.ok?
          validations.result.attributes
        else
          status 400
          { errors: validations.errors }
        end
      rescue Repository::RecordNotFound
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
