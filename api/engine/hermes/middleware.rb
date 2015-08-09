require_relative './travel'

module Hermes
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Travel.new(env).possible? or
        return missing_collection

      @app.(env)
    end

    private

    def missing_collection
      Rack::Response.new \
        [{ errors: ['Collection could not found'] }.to_json],
        404,
        { 'Content-Type' => 'application/json' }
    end
  end
end
