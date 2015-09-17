ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'

require File.expand_path('../../config/application', __FILE__)

require './api/server'

require 'pry'

require 'timecop'
require 'database_cleaner'
require 'factory_girl'
require 'faker'
require_relative 'api_spec_helpers'
require_relative 'api_spec_expectations'
require_relative 'factories/fabrics'

require 'sidekiq/testing'
Sidekiq::Testing.fake!

require 'did_you_mean'

ActiveRecord::Base.logger.level = 1

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include ApiSpecHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
    REDIS_CLIENT.flushdb
  end

  config.after(:each) do
    Grape::Endpoint.before_each nil
  end
end

def app
  API
end
