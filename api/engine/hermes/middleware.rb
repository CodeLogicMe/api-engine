require_relative './travel'
require_relative '../../measure'

module Hermes
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      travel = measure(Travel.new(env))

      travel.possible? or
        return missing_collection

      @app.(env)
    end

    private

    def missing_collection
      Rack::Response.new \
        [{ errors: ['Collection could not be found'] }.to_json],
        404,
        { 'Content-Type' => 'application/json' }
    end

    def measure(travel)
      Measure.new travel, {
        :possible? => 'Hermes is checking the routing'
      }
    end
  end
end
