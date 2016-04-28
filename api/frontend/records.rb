require "grape"
require_relative "auth_helpers"

module Frontend
  class Records < Grape::API
    resource :records do
      helpers AuthHelpers

      before { authenticate! }

      get do
        records = current_client.collections
          .find_by(system_name: params.collection)
          .records

        { records: records.map(&:to_h) }
      end
    end
  end
end
