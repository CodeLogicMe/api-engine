require 'grape'
require 'rack/cors'
require_relative '../business/setup'
require_relative './helpers'
require_relative './resources'

module Authentik
  class API < ::Grape::API
    version 'v1', using: :header, vendor: 'authentik'
    format :json
    prefix :api

    use Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [ :get, :post, :put, :delete, :options ]
      end
    end

    helpers AuthHelpers

    mount Resources::Auth
    mount Resources::Users
  end
end
