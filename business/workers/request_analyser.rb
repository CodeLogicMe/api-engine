require 'sidekiq'
require_relative '../models/smart_request'

module Workers
  class RequestAnalyser
    include Sidekiq::Worker

    require 'geocoder'

    def perform(data)
      Models::SmartRequest.create! \
        geolocation: geolocation_from(data)
    end

    private

    def geolocation_from(data)
      Geocoder.search(data.fetch('ip_address')).first.data
    end
  end
end
