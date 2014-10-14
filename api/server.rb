require 'grape'
require_relative '../business/setup'

module Authentik
  class API < Grape::API
    version 'v1', using: :header, vendor: 'authentik'
    format :json
    prefix :api

    desc 'Authentication endpoint'
    post :auth do

    end

    desc 'Display all users for a given app'
    params do
      requires :app_key, type: String
      requires :app_pass, type: String
    end
    resource :users do
      get do
        Models::User.all
      end
    end

    resource :apps do
      get do
        Models::App.all
      end
    end
  end
end
