ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'bundler/setup'
require 'require_all'

if %w(development test).include? ENV['RACK_ENV']
  require 'dotenv'
  Dotenv.load
end

require_all 'config/initializers/*.rb'
