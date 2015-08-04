require 'grape'
require_relative 'middlewares/janus'

module Engine
  class Authentication < Grape::API
    use Middlewares::Janus

    helpers do
      def current_api
        env.fetch 'current_api'
      end
    end

    desc 'Authentication test endpoint' do
      failure [401, 'Unauthorized']
      headers [
        'X-Access-Token' => {
          description: 'Identifies the API',
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
        { api: current_api.name }
      end

      post do
        status 201
        { api: current_api.name }
      end

      delete '/:id' do
        status 200
        { api: current_api.name }
      end

      put '/:id' do
        status 200
        { api: current_api.name }
      end
    end
  end
end
