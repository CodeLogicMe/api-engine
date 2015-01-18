require 'sinatra/namespace'

require_relative './helpers'

module RestInMe
  class Apps < Sinatra::Base
    register Sinatra::Namespace

    helpers Helpers::ClientAccess

    namespace '/apps' do
      get '/?' do
        @apps = current_client.apps
        erb :apps, layout: :skeleton
      end

      get '/new' do
        @app = Models::App.new
        erb :new_app, layout: :skeleton
      end

      post '/?' do
        params['app'].merge!(client: current_client)
        @app = Actions::CreateApp.new(params['app']).call do |app|
          erb :new_app, layout: :skeleton
          return
        end

        redirect to("/apps/#{app.system_name}")
      end

      get '/:slug/?' do
        @app = current_client.apps.find_by(system_name: params['slug'])
        erb :app_detail, layout: :skeleton
      end
    end
  end
end
