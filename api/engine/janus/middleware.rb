require_relative './request'
require 'skylight'

module Janus
  class Middleware
    include Skylight::Helpers

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Request.new(env)

      Skylight.instrument title: 'Janus is authenticating' do
        request.identifiable? or
          return missing_api

        request.valid? or
          return unauthorized
      end

      env.merge!('current_api' => request.api)

      @app.(env)
    end

    private

    def missing_api
      Rack::Response.new \
        [{ errors: ['API could not found'] }.to_json],
        404,
        { 'Content-Type' => 'application/json' }
    end

    def unauthorized
      Rack::Response.new \
        [{ errors: ['Unauthorized'] }.to_json],
        401,
        { 'Content-Type' => 'application/json' }
    end
  end
end
