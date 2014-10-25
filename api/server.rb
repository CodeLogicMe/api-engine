require 'grape'
require_relative '../business/setup'

module Authentik
  class API < Grape::API
    version 'v1', using: :header, vendor: 'authentik'
    format :json
    prefix :api

    desc 'Authentication endpoint'
    params do
      requires :public_key, type: String
      requires :private_key, type: String
    end
    post :authenticate do
      Actions::AuthenticateApp.new(params).call
      status 202 and {result: 'ready to rumble!!!'}
    end
  end
end
