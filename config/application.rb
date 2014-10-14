ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'bundler/setup'
require 'require_all'

require_all 'config/initializers/*.rb'
