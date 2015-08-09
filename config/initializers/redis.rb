require 'hiredis'
require 'redis'

dbs = {
  'development' => 0,
  'test' => 1,
  'production' => 2
}

REDIS_CLIENT = Redis.new \
  driver: :hiredis,
  db: dbs[ENV["RACK_ENV"]]
