require 'grape'
require_relative '../business/setup'

module Authentik
  class API < Grape::API
    version 'v1', using: :header, vendor: 'authentik'
    format :json
    prefix :api

    desc 'Authentication test endpoint' do
      failure [[401, 'Unauthorized', "Entities::Error"]]
      headers [
        'PublicKey' => {
          description: 'Identifies the Application',
          required: true
        },
        'Hmac' => {
          description: 'A hashed composed by the request timestamp, params and your private key'
        }
      ]
    end
    get :authenticate do
      data = {
        query_string: env.fetch('QUERY_STRING'),
        auth: {
          hmac: headers.fetch('Hmac'),
          public_key: headers.fetch('Publickey')
        }
      }
      Actions::AuthenticateApp.new(data).call do
        error!({ message: 'Unauthorized' }, 401)
      end
      status 202 and {result: 'Ready to rumble!!!'}
    end
  end
end
