require 'sinatra'
require_relative './assets_server'

module RestInMe
  class Frontend < Sinatra::Base
    set :public_folder, File.dirname(__FILE__) + '/public'

    helpers do
      def current_client
        client_id = request.cookies['client_id']

        return Models::NilClient.new if client_id.nil?

        @client ||= Models::Client.find(client_id)
      end

      def set_current_client(client)
        @client = client
        response.set_cookie 'client_id',
          { value: client.id.to_s, max_age: '604800' }
      end
    end

    get '/' do
      erb :home, layout: :skeleton
    end

    use AssetsServer

    get '/dashboard' do
      @apps = current_client.apps
      erb :dashboard, layout: :skeleton
    end

    post '/sign_in' do
      client = Models::Client.authenticate params[:client]

      if client
        set_current_client client

        redirect to('/dashboard')
      else
        redirect to('/sign_in')
      end
    end

    post '/sign_up' do
      client = Models::Client.create params[:client]

      if client
        set_current_client client

        redirect to('/dashboard')
      else
        redirect to('/sign_up')
      end
    end
  end
end
