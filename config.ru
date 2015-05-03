require File.expand_path('../config/application', __FILE__)

require './api/server'

run API.new
