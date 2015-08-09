module Hermes
  class Travel
    def initialize(env)
      @api = env.fetch 'current_api'
      @collection = env.fetch('rack.routing_args')
        .fetch(:collection_name, 'missing')
    end

    def possible?
      return false if @collection == 'missing'

      @api.has_collection? @collection
    end
  end
end
