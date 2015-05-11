module Middlewares
  class Veritas < Grape::Middleware::Base
    def initialize(app)
      @app = app
    end

    def call(env)
      #p env
      @app.call env
    end
  end
end
