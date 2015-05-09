class Resources::Authentication < Grape::API
  before { authenticate_app! }

  desc 'Authentication test endpoint' do
    failure [401, 'Unauthorized']
    headers [
      'X-Access-Token' => {
        description: 'Identifies the Application',
        required: true
      },
      'X-Request-Timestamp' => {
        description: 'When the request was constructed',
        required: true
      },
      'X-Request-Hash' => {
        description: 'A hashed composed by the private key and the query string',
        required: true
      }
    ]
  end
  get :authenticate do
    status 200
    { app: current_app.name }
  end

  post :authenticate do
    status 201
    { app: current_app.name }
  end

  delete 'authenticate/:id' do
    status 200
    { app: current_app.name }
  end

  put 'authenticate/:id' do
    status 200
    { app: current_app.name }
  end
end
