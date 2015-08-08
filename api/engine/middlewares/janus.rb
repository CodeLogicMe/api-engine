module Middlewares
  class Janus
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Request.new(env)

      request.identifiable? or
        return missing_api

      request.valid? or
        return unauthorized

      env['current_api'] = request.api

      @app.call env
    end

    private

    def missing_api
      [
        404,
        { 'Content-Type' => 'application/json' },
        [{ errors: ['Not Found'] }.to_json]
      ]
    end

    def unauthorized
      [
        401,
        { 'Content-Type' => 'application/json' },
        [{ errors: ['Unauthorized'] }.to_json]
      ]
    end

    class Request
      require "forwardable"
      extend Forwardable

      def initialize(env)
        @verb = env.fetch 'REQUEST_METHOD'
        @query_string = Rack::Request.new(env).params.to_query

        @auth = Auth.new(headers_on(env))
      end

      def_delegators :@auth, :api, :timestamp, :identifiable?, :request_hash

      def valid?
        @auth.valid?(@verb, @query_string)
      end

      private

      def headers_on(env)
        pairs = env
          .select { |k,v| k.start_with? 'HTTP_' }
          .map { |pair| [pair[0].sub(/^HTTP_/, ''), pair[1]] }
        Hash[pairs]
      end
    end

    class Auth
      TOLERANCE = 1.minute

      attr_reader :hash, :timestamp, :public_key, :request_hash

      def initialize(headers)
        @public_key = headers.fetch('X_ACCESS_TOKEN') { 'missing' }
        @timestamp = headers.fetch('X_REQUEST_TIMESTAMP') { 'missing' }
        @request_hash = headers.fetch('X_REQUEST_HASH') { 'missing' }
      end

      def identifiable?
        ( @public_key != 'missing' ) and ( api.present? )
      end

      def api
        @api ||= Models::Api
          .includes(:private_key)
          .find_by(public_key: @public_key)
      end

      def valid?(verb, query)
        has_all_info? and
          ( not expired? ) and hash_checks?(verb, query)
      end

      private

      def has_all_info?
        [@public_key, @timestamp, @request_hash]
          .all? { |value| value != 'missing' }
      end

      def expired?
        timestamp = Time.at(@timestamp.to_i).to_i
        now_utc = Time.now.utc.to_i
        ( now_utc - TOLERANCE ) > timestamp
      end

      def hash_checks?(verb, query)
        hash = OpenSSL::HMAC.hexdigest \
          OpenSSL::Digest.new('sha1'),
          api.private_key.secret,
          request_string(verb, query)

        @request_hash == hash
      end

      def request_string(verb, query)
        verb + @timestamp + query
      end
    end
  end
end
