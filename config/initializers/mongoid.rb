require 'mongoid'

Mongoid.load! 'config/mongoid.yml', ENV['RACK_ENV']

if ENV['RACK_ENV'] == 'development'
  Mongoid.logger.level = Logger::DEBUG
  Moped.logger.level = Logger::DEBUG
  Mongoid.logger = Logger.new($stdout)
  Moped.logger = Logger.new($stdout)
end
