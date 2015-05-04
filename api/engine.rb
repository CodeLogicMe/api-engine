require 'grape'

require_relative './helpers'
require_rel './resources/*.rb'

class Engine < Grape::API
  version 'v1', using: :header, vendor: 'restinme'
  format :json
  content_type :json, 'application/json'

  use ::Rack::Cors do
    allow do
      origins '*'
      resource '*',
        headers: :any,
        methods: %i( get post put delete options )
    end
  end

  helpers ::AuthHelpers

  mount ::Resources::Authentication
  mount ::Resources::Endpoints
end
