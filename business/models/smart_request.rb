module Models
  class SmartRequest
    include Mongoid::Document

    store_in collection: 'smart_requests'

    embedded_in :app

    field :status, type: Integer
    field :geolocation, type: Hash
    field :browser, type: String
    field :platform, type: String
    field :started_at, type: DateTime
    field :ended_at, type: DateTime
    field :duration, type: Float

    validates_presence_of :geolocation
  end
end
