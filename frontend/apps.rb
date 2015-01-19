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

      get '/new/?' do
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

      namespace '/:slug' do
        helpers do
          def current_app
            current_client.apps.find_by(system_name: params['slug'])
          end

          def entity_field_types
            [
              OpenStruct.new(name: 'String', value: 'string'),
              OpenStruct.new(name: 'Integer', value: 'integer')
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

          AddEntity
            .new(params['entity'])
            .call(current_app)

          {} and status 204
        end
      end
    end
  end
end
