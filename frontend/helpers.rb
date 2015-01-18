module RestInMe
  module Helpers
    module ClientAccess
      def current_client
        client_id = request.cookies['client_id']

        return Models::NilClient.new if client_id.nil?

        @client ||= Models::Client.find(client_id)
      end

      def set_current_client(client)
        @client = client
        response.set_cookie 'client_id',
          { value: client.id.to_s, max_age: '604800' }
      end
    end
  end
end
