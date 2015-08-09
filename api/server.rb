require 'grape'
require 'rack/cors'

require_relative 'response_normalizer'
require 'skylight'

require_relative '../business/setup'

require_relative 'engine/authentication'
require_relative 'engine/collection'

require_relative 'frontend/login'
require_relative 'frontend/apis'
require_relative 'frontend/collections'
require_relative 'frontend/fields'
require_relative 'frontend/tiers'
require_relative 'frontend/statistics'

class API < Grape::API
  use ::Rack::Cors do
    allow do
      origins '*'
      resource '*',
        headers: :any,
        methods: %i( get post put delete options )
    end
  end

  format :json
  content_type :json, 'application/json'

  use Skylight::Middleware
  use ResponseNormalizer

  namespace :engine do
    mount Engine::Authentication
    mount Engine::Collection
  end

  namespace :api do
    mount Frontend::Login
    mount Frontend::Apis
    mount Frontend::Collections
    mount Frontend::Fields
    mount Frontend::Tiers
    mount Frontend::Statistics
  end
end
