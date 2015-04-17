require 'sinatra/base'
require 'sinatra/namespace'

class AppBuilder < Sinatra::Base
  register Sinatra::Namespace

  helpers Helpers::ClientAccess

  namespace '/builder' do
    get '/?' do
      erb :app_builder, layout: :app_builder_layout
    end
  end
end
