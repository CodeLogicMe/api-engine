require 'hiredis'
require 'redis'

REDIS_CLIENT = Redis.new(driver: :hiredis)
