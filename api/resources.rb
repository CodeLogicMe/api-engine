module Authk
  class Resources::Auth < Grape::API
    before { authenticate_app! }

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
      status 202 and { app: current_app.name }
    end
  end

  class Resources::Users < Grape::API
    resources :users do
      desc 'Authenticate the user for the current app'
      params do
        requires :email, type: String, regexp: /.+@.+/, desc: 'User email'
        requires :password, type: String, desc: 'User password'
      end
      post :authenticate do
        data = { app: current_app, email: params[:email], password: params[:password] }
        user = Actions::AuthenticateUser.new(data).call do
          error!({}, 404)
        end
        status 202 and { id: user.id.to_s, email: user.email }
      end

      desc 'List all users for the current app'
      get do
        users = current_app.users.all
        {
          total: users.count,
          list: users.map { |user|
            { id: user.id, email: user.email }
          }
        }
      end

      desc 'Creates an user for the current app'
      params do
        requires :email, type: String, regexp: /.+@.+/, desc: 'User email'
        requires :password, type: String, desc: 'User password'
      end
      post do
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
