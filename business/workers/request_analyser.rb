require 'sidekiq'
require 'browser'
require_relative '../models/app'
require_relative '../models/smart_request'

module Workers
  class RequestAnalyser
    include Sidekiq::Worker

    require 'geocoder'

    def perform(api_id, data)
      Models::App.find(api_id).requests.create! \
        geolocation: geolocation_from(data),
        browser: browser(data).name,
        platform: browser(data).platform,
        started_at: data['started_at'],
        ended_at: data['ended_at'],
        duration: data['duration']
    end

    private

    def geolocation_from(data)
      Geocoder.search(data.fetch('ip_address')).first.data
    end

    def browser(data)
      @browser ||=
        begin
          Browser.new \
            ua: data.fetch('user_agent'),
            accept_language: data.fetch('language')
        end
    end
  end
end
