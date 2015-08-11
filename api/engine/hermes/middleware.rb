require_relative './travel'
require 'skylight'

module Hermes
  class Middleware
    include Skylight::Helpers

    def initialize(app)
      @app = app
    end

    def call(env)
      Skylight.instrument title: 'Hermes is checking the routing' do
        Travel.new(env).possible? or
          return missing_collection
      end

      @app.(env)
    end

    private

    def missing_collection
      Rack::Response.new \
        [{ errors: ['Collection could not be found'] }.to_json],
        404,
        { 'Content-Type' => 'application/json' }
    end
  end
end
