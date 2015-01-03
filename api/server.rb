require 'grape'
require 'rack/cors'
require_relative '../business/setup'
require_relative './helpers'
require_all 'api/resources/*.rb'

module RestInMe
  class API < ::Grape::API
    version 'v1', using: :header, vendor: 'restinme'
    format :json
    prefix :api

    use Rack::Cors do
      allow do
        origins '*'
        resource '*',
        headers: :any,
        methods: [ :get, :post, :put, :delete, :options ]
      end
    end

    helpers AuthHelpers

    mount Resources::Authentication
    mount Resources::Users
  end
end
