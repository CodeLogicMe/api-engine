module Hermes
  module Helpers
    def collection_name
      params.fetch :collection_name
    end

    def collection
      @collection ||= current_api.collections
        .find_by!(system_name: collection_name)
    end

    def collection_params
      (params.data || {}).select do |key, value|
        collection.has_field?(key)
      end
    end

    def current_repository
      ::Repository.new collection
    end
  end
end
