module Authk
  module AuthHelpers
    extend ::Grape::API::Helpers

    def authenticate_app!
      unless @current_app
        data = { verb: verb, auth: auth_keys, query_string: params_string }
        @current_app = Actions::AuthenticateApp.new(data).call do
          error!({ message: 'Unauthorized' }, 401)
        end
      end
    end

    def current_app
      @current_app ||= authenticate_app!
    end

    private
    def verb
      env.fetch('REQUEST_METHOD')
    end

    def params_string
      case env.fetch('REQUEST_METHOD')
      when 'GET'
        env.fetch('QUERY_STRING')
      else
        env.fetch('rack.request.form_hash').to_query
      end
    end

    def auth_keys
      {
        hmac: headers.fetch('Hmac'),
        timestamp: headers.fetch('Timestamp'),
        public_key: headers.fetch('Publickey')
      }
    end
  end
end
