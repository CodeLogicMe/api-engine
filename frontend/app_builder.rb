require 'sinatra/base'
require 'sinatra/namespace'

class AppBuilder < Sinatra::Base
  register Sinatra::Namespace

  helpers Helpers::ClientAccess
  helpers Helpers::Assets

  namespace '/builder' do
    get '/?' do
      @app_config =
        if params[:app].present?
          current_client
            .apps
            .find_by(system_name: params[:app])
            .app_config
        else
          { entities: [] }
        end
      erb :app_builder, layout: :app_builder_layout
    end
  end
end
