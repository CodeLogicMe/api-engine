require "sinatra"

require_relative "./assets_server"
require_relative "./my_apps"

class Frontend < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + "/public"

  use AssetsServer
  use MyApps

  helpers Helpers::ClientAccess

  get '/' do
    if current_client.signed_in?
      redirect to('/my_apps')
    else
      erb :landing, layout: :skeleton
    end
  end

  post '/sign_in' do
    client = Models::Client.authenticate params[:client]

    if client
      set_current_client client

      redirect to('/my_apps')
    else
      redirect to('/')
    end
  end

  post '/sign_up' do
    client = Models::Client.create params[:client]

    if client
      set_current_client client

      redirect to('/my_apps')
    else
      redirect to('/landing')
    end
  end
end
