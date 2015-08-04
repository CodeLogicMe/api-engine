require 'grape'
require_relative 'auth_helpers'
require_relative '../../business/contexts/authenticable_client'

module Frontend
  class Login < Grape::API
    helpers AuthHelpers

    post :login do
      client = Contexts::AuthenticableClient
        .authenticate(*params.values_at(:email, :password))
      if client.signed_in?
        current_client = client
        { token: client.token }
      else
        status 400
      end
    end
  end
end
