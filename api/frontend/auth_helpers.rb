require_relative '../../business/services/auth_token'

module Frontend
  module AuthHelpers
    def current_client
      return nil if headers['Authorization'].nil?

      @current_client ||=
        begin
          client_id = Services::AuthToken.retrieve(headers['Authorization'])
          return nil unless client_id
          Models::Client.find client_id
        end
    end

    def current_client=(client)
      @current_client = client
    end

    def authenticate!
      unless current_client
        error!('401 Unauthorized', 401, 'Access-Control-Allow-Origin' => '*')
      end
    end
  end
end
