module Models
  class SmartRequest
    include Mongoid::Document

    store_in collection: 'smart_requests'

    field :geolocation, type: Hash
  end
end
