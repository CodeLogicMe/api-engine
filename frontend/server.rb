require 'sinatra'

require_relative './assets_server'
require_relative './apps'

module RestInMe
  class Frontend < Sinatra::Base
    set :public_folder, File.dirname(__FILE__) + '/public'

    use AssetsServer
    use Apps

    helpers Helpers::ClientAccess

    get "/" do
      if current_client.signed_in?
        redirect to("/apps")
      else
        erb :landing, layout: :skeleton
      end
    end

    post '/sign_in' do
      client = Models::Client.authenticate params[:client]

      if client
        set_current_client client

        redirect to('/apps')
      else
        redirect to('/landing')
      end
    end

    post '/sign_up' do
      client = Models::Client.create params[:client]

      if client
        set_current_client client

        redirect to('/apps')
      else
        redirect to('/landing')
      end
    end
  end
end
