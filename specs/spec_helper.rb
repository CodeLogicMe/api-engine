ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'

require File.expand_path('../../config/application', __FILE__)

require './api/server'
require './frontend/server'

require 'pry'

require 'database_cleaner'
require 'factory_girl'
require 'faker'
require_relative 'factories/fabrics'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

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
  end
end

def app
  API.new
end
def last_json
  Hashie::Mash.new JSON.parse(last_response.body)
end
def calculate_hmac(verb, private_key, params, timestamp)
  digest = OpenSSL::Digest.new('sha1')
  data = verb + timestamp.to_s + params.to_query
  OpenSSL::HMAC.hexdigest(digest, private_key, data)
end
def set_auth_headers_for!(app, verb, params)
  timestamp = Time.now.utc.to_i
  header 'X-Access-Token', app.public_key
  header 'X-Request-Timestamp', timestamp.to_s
  header 'X-Request-Hash', calculate_hmac(verb, app.private_key.secret, params, timestamp)
end
