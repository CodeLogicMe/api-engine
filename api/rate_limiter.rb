require 'redis-namespace'

module RateLimiter
  STORE = Redis::Namespace.new(:hit_counts, redis: Redis.new)

  def self.valid?(app)
    not Quota.new(app).over?
  end

  def self.hit(app)
    Quota.new(app).hit!
  end

  Quota ||= Struct.new(:app) do
    def over?
      hit_count >= app.tier.quota
    end

    def hit_count
      RateLimiter::STORE.get(app.id.to_s).to_i || 0
    end

    def hit!
      RateLimiter::STORE.incr app.id.to_s
    end
  end
end
