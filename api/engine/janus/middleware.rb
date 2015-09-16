require_relative './request'
require_relative '../../measure'

module Janus
  class Middleware
    include Skylight::Helpers

    def initialize(app)
      @app = app
    end

    def call(env)
      request = measure(Request.new(env))

      request.identifiable? or
        return missing_api

      request.valid? or
        return unauthorized

      env.merge!('current_api' => request.api)

      @app.(env)
    end

    private

    def missing_api
      Rack::Response.new \
        [{ errors: ['API could not be found'] }.to_json],
        404,
        { 'Content-Type' => 'application/json' }
    end

    def unauthorized
      Rack::Response.new \
        [{ errors: ['Unauthorized'] }.to_json],
        401,
        { 'Content-Type' => 'application/json' }
    end

    def measure(request)
      Measure.new request, {
        :identifiable? => 'Janus is identifying the API',
        :valid? => "Janus is authorizing the API's request"
      }
    end
  end
end
