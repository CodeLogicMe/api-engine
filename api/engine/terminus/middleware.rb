module Terminus
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      quota = Quota.new(env['current_api'])

      quota.over? and
        return forbidden

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
