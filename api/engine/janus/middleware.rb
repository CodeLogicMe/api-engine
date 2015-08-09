require_relative './request'

module Janus
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Request.new(env)

      request.identifiable? or
        return missing_api

      request.valid? or
        return unauthorized

      @app.(env.merge('current_api' => request.api))
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
