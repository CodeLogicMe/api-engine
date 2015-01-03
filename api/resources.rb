module RestInMe
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
      status 200 and { app: current_app.name }
    end
  end

  class Resources::Users < Grape::API
    before { authenticate_app! }

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
        status 200 and { id: user.id.to_s, email: user.email }
      end

      desc 'List all users for the current app'
      get do
        users = current_app.users.all
        {
          total: users.count,
          list: users.map { |user|
            {
              id: user.id.to_s,
              email: user.email
            }
          }
        }
      end

      desc 'Creates an user for the current app'
      params do
        requires :email, type: String, regexp: /.+@.+/, desc: 'User email'
        requires :password, type: String, desc: 'User password'
      end
      post do
        data = { app: current_app, params: params }
        user = Actions::CreateUser.new(data).call do |errors|
          error!({ errors: errors }, 400)
        end
        { id: user.id, email: user.email, data: user.loose_data.to_h }
      end

      desc "Updates user data"
      params do
        requires :id, type: String, desc: 'User identifier'
        requires :data, type: Hash, desc: 'User data hash'
      end
      put '/:id/data' do
        data = {
          app: current_app,
          user_id: params[:id],
          data: params[:data]
        }
        loose_data = Actions::SetLooseData.new(data).call do
          error!({}, 404)
        end
        status 201 and { data: loose_data.to_h }
      end
    end
  end
end
