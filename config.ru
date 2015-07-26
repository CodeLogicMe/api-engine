require File.expand_path('../config/application', __FILE__)

require './api/server'

use ActiveRecord::ConnectionAdapters::ConnectionManagement
run API.new
