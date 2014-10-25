ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'

require File.expand_path('../../config/application', __FILE__)

require './api/server'
require './frontend/server'

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
  Authentik::API.new
end
def last_json
  JSON.parse(last_response.body)
end
def calculate_hmac(private_key, params)
  digest = OpenSSL::Digest.new('sha1')
  data = params.to_query
  hmac = OpenSSL::HMAC.digest(digest, private_key, data)
end
def set_auth_headers_for!(app, params)
  header 'PublicKey', app.public_key
  header 'Hmac', calculate_hmac(app.private_key.secret, params)
end
