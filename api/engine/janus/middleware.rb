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
      [
        404,
        { 'Content-Type' => 'application/json' },
        [{ errors: ['Not Found'] }.to_json]
      ]
    end

    def unauthorized
      [
        401,
        { 'Content-Type' => 'application/json' },
        [{ errors: ['Unauthorized'] }.to_json]
      ]
    end
  end
end
