require 'redis-namespace'

module Terminus
  class Quota
    STORE = Redis::Namespace.new(:hit_counts, redis: ::REDIS_CLIENT)

    def initialize(api)
      @api = api
    end

    def over?
      hit_count >= @api.tier.quota
    end

    def hit_count
      STORE.get(@api.id.to_s).to_i || 0
    end

    def hit!
      yield.tap do |response|
        [500].include?(response.status) or
          STORE.incr(@api.id.to_s)
      end
    end
  end
end
