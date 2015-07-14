require 'redis'
require 'redis-namespace'
require 'securerandom'
require_relative '../../config/initializers/redis'

module Services::AuthToken
  STORE = Redis::Namespace.new(:tokens, redis: ::REDIS_CLIENT)

  class << self
    def retrieve(token)
      STORE.get token.split(' ')[1]
    end

    def generate(client)
      token = SecureRandom.uuid
      STORE.set token, client.id
      token
    end
  end
end
