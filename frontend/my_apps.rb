require "sinatra/base"
require "sinatra/namespace"

require_relative "./helpers"

class MyApps < Sinatra::Base
  register Sinatra::Namespace

  helpers Helpers::ClientAccess

  namespace "/my_apps" do
    before do
      unless current_client.signed_in?
        redirect "/"
      end
    end

    get "/?" do
      @apps = current_client.apps
      erb :my_apps, layout: :application
    end

    get "/new/?" do
      @app = Models::App.new
      erb :new_app, layout: :application
    end

    post "/?" do
      params["app"].merge!(client: current_client)
      @app = Actions::CreateApp.new(params["app"]).call do |app|
        erb :new_app, layout: :application
        return
      end

      redirect to("/apps/#{app.system_name}")
    end

    namespace "/:slug" do
      helpers do
        def current_app
          current_client.apps.find_by(system_name: params['slug'])
        end

        def entity_field_types
          [
            OpenStruct.new(name: "String", value: "string"),
            OpenStruct.new(name: "Integer", value: "integer")
          ]
        end

        def select_tag(name, options:)
          <<-TAG
              <select name="#{name}\" data-key="#{name}">
          #{options.map { |opt| option_tag(opt) }.join}
              </select>
          TAG
        end

        def option_tag(option)
          "<option value=#{option.value}>#{option.name}</option>"
        end
      end

      get '/?' do
        @app = current_app
        erb :app_detail, layout: :skeleton
      end

      get '/new_entity/?' do
        @app = current_app
        erb :new_entity, layout: :skeleton
      end

      put '/new_entity/?' do
        params['entity']['fields'] =
          params['entity']['fields'].values

        Actions::AddEntity
          .new(params['entity'])
          .call(current_app)

        {} and status 204
      end
    end
  end

  helpers do
    def app_path(model_or_id)
      "/my_apps/#{model_or_id.to_param}"
    end

    def app_tier_path(model_or_id)
      "/my_apps/#{model_or_id.to_param}/config#tier"
    end
  end
end
