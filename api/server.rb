require 'grape'
require 'rack/cors'

require_relative '../business/setup'
require_relative './engine'
require_relative './frontend'

class API < Grape::API
  use ::Rack::Cors do
    allow do
      origins '*'
      resource '*',
        headers: :any,
        methods: %i( get post put delete options )
    end
  end

  mount Engine
  mount Frontend => '/api'
end
