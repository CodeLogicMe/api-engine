module Authk
  class Resources::Auth < Grape::API
    desc 'Authentication test endpoint' do
      failure [401, 'Unauthorized']
      headers [
        'PublicKey' => {
          description: 'Identifies the Application',
          required: true
        },
        'Hmac' => {
          description: 'A hashed composed by the private key and the query string'
        }
      ]
    end
    get :authenticate do
      authenticate_app!
      status 202 and { result: 'Ready to rumble!!!' }
    end
  end

  class Resources::Users < Grape::API
    resources do
      desc 'Creates an user for the current app'
      params do
        requires :email, type: String, regexp: /.+@.+/
        requires :password, type: String
      end
      post :users do
        authenticate_app!
        data = { app: current_app, params: params }
        user = Actions::CreateUser.new(data).call do |errors|
          error!({ errors: errors }, 400)
        end
        { id: user.id, email: user.email }
      end
    end
  end
end
