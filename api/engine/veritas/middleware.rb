require_relative './tracker'

module Veritas
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Timing.track(env) do
        @app.(env)
      end
    end
  end
end
