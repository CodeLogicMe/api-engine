require 'redis-namespace'

module Middlewares
  class Terminus
    def initialize(app)
      @app = app
    end

    def call(env)
      quota = Quota.new(env['current_api'])

      if quota.over?
        return [
          403,
          { 'Content-Type' => 'application/json' },
          [{ errors: ['Forbidden'] }.to_json]
        ]
      end

      response = @app.call env

      unless [500].include? response[0]
        quota.hit!
      end

      response
    end

    def self.quota_for(api)
      Quota.new(api).hit_count
    end

    Quota ||= Struct.new(:api) do
      STORE = Redis::Namespace.new(:hit_counts, redis: ::REDIS_CLIENT)

      def over?
        hit_count >= api.tier.quota
      end

      def hit_count
        STORE.get(api.id.to_s).to_i || 0
      end

      def hit!
        STORE.incr api.id.to_s
      end
    end
  end
end
