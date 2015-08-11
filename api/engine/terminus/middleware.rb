require_relative 'quota'
require 'skylight'

module Terminus
  class Middleware
    include Skylight::Helpers

    def initialize(app)
      @app = app
    end

    def call(env)
      quota = Quota.new(env['current_api'])

      Skylight.instrument title: 'Terminus is verifying the quota' do
        quota.over? and
          return forbidden
      end

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
  end
end
