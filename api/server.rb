require 'grape'
require 'rack/cors'
require 'grape_logging'

require_relative '../business/setup'
require_relative './engine'
require_relative './frontend'

class API < Grape::API
  if ENV['RACK_ENV'] == 'production'
    logger Logger.new GrapeLogging::MultiIO.new(STDOUT, File.open(File.join(__dir__, "../../../shared/log/production.log"), 'a'))
  else
    logger Logger.new GrapeLogging::MultiIO.new(STDOUT, File.open(File.join(__dir__, "../log/#{ENV['RACK_ENV']}.log"), 'a'))
  end

  require 'logger'
  Logger.class_eval { alias :write :'<<' }
  logger = ::Logger.new(::File.new("log/app.log","a+"))

  use Rack::CommonLogger, logger

  rescue_from :all do |e|
    MyAPI.logger.error e
  end

  use ::Rack::Cors do
    allow do
      origins '*'
      resource '*',
        headers: :any,
        methods: %i( get post put delete options )
    end
  end

  mount Engine => '/api'
  mount Frontend
end
