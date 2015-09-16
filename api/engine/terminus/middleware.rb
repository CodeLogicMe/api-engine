require_relative 'quota'
require_relative '../../measure'

module Terminus
  class Middleware
    include Skylight::Helpers

    def initialize(app)
      @app = app
    end

    def call(env)
      quota = measure(Quota.new(env['current_api']))

      quota.over? and
        return forbidden

      quota.hit! do
        @app.(env)
      end
    end

    private

    def forbidden
      Rack::Response.new \
        [{ errors: ['Forbidden'] }.to_json],
        403,
        { 'Content-Type' => 'application/json' }
    end

    def measure(quota)
      Measure.new quota, {
        :over? => 'Terminus is verifying the quota',
        :hit! => 'Terminus is registering a hit'
      }
    end
  end
end
