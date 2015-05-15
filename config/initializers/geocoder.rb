require 'geocoder'
require 'redis-namespace'

Geocoder.configure \
  cache: Redis::Namespace.new(:geocoder_cache, redis: Redis.new)
