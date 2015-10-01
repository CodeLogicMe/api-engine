require_relative '../models/password'

module Contexts
  module AuthenticableClient
    extend self

    def authenticate(email, password)
      client = Models::Client.find_by!(email: email)
      if client.password == Password.new(password)
        token = Services::AuthToken.generate(client)
        Authenticated.new client, token
      else
        Unauthenticated.new
      end
    rescue ActiveRecord::RecordNotFound
      Unauthenticated.new
    end

    private

    class Authenticated < SimpleDelegator
      def initialize(client, token)
        super client
        @token = token
      end

      attr_reader :token

      def signed_in?
        true
      end
    end

    class Unauthenticated
      def signed_in?
        false
      end
    end
  end
end
