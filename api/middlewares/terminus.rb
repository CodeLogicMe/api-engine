require 'redis-namespace'

module Middlewares
  class Terminus
    STORE = Redis::Namespace.new(:hit_counts, redis: Redis.new)

    def initialize(app)
      @app = app
    end

    def call(env)
      quota = Quota.new(env['current_api'])

      if quota.over?
        return Rack::Response.new({ errors: 'Forbidden' }, 403)
      end

      response = @app.call env

      quota.hit!

      response
    end

    def self.quota_for(app)
      Quota.new(app).hit_count
    end

    Quota ||= Struct.new(:app) do
      def over?
        hit_count >= app.tier.quota
      end

      def hit_count
        STORE.get(app.id.to_s).to_i || 0
      end

      def hit!
        STORE.incr app.id.to_s
      end
    end
  end
end
