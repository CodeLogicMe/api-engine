module Authentik
  module AuthHelpers
    extend ::Grape::API::Helpers

    def authenticate_app!
      unless @current_app
        data = { auth: auth_keys, query_string: params_string }
        @current_app = Actions::AuthenticateApp.new(data).call do
          error!({ message: 'Unauthorized' }, 401)
        end
      end
    end

    def current_app
      @current_app ||= authenticate_app!
    end

    private
    def params_string
      case env["REQUEST_METHOD"]
      when 'GET'
        env.fetch('QUERY_STRING')
      when 'POST'
        env['rack.request.form_hash'].to_query
      end
    end

    def auth_keys
      {
        hmac: headers.fetch('Hmac'),
        public_key: headers.fetch('Publickey')
      }
    end
  end
end
