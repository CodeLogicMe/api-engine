require "sinatra"

require_relative "./assets_server"
require_relative "./my_apps"
require_relative './app_builder'

class Frontend < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + "/public"

  use AssetsServer
  use MyApps
  use AppBuilder

  helpers Helpers::ClientAccess

  before do
    unless current_client.signed_in?
      redirect '/'
    end
  end

  get '/' do
    if current_client.signed_in?
      redirect to('/my_apps')
    end

    erb :landing, layout: :skeleton
  end

  get '/sign_in' do
    erb :sign_in, layout: :skeleton
  end

  post '/sign_in' do
    client = Models::Client.authenticate params[:client]

    if client
      set_current_client client

      redirect to('/my_apps')
    else
      redirect to('/sign_in')
    end
  end

  get '/sign_up' do
    erb :sign_up, layout: :skeleton
  end

  post '/sign_up' do
    client = Models::Client.create params[:client]

    if client
      set_current_client client

      redirect to('/my_apps')
    else
      redirect to('/sign_up')
    end
  end
end
