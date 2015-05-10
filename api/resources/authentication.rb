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
  namespace :authenticate do
    get do
      status 200
      { app: current_app.name }
    end

    post do
      status 201
      { app: current_app.name }
    end

    delete '/:id' do
      status 200
      { app: current_app.name }
    end

    put '/:id' do
      status 200
      { app: current_app.name }
    end
  end
end
