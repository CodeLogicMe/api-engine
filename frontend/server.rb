require 'sinatra'

module Authk
  class Frontend < Sinatra::Base
    set :public_folder, File.dirname(__FILE__) + '/public'

    get '/' do
      erb :home, layout: :skeleton
    end

    post '/apps' do
      app = Models::App.create \
        name: name,
        client: Models::Client.find(client_id)
    end
  end
end
