require 'forwardable'
require_relative './auth'

module Janus
  class Request
    extend Forwardable

    def initialize(env)
      @verb = env.fetch 'REQUEST_METHOD'
      @query_string = Rack::Request.new(env).params.to_query

      @auth = Auth.new(headers_on(env))
    end

    def_delegators :@auth, :api, :identifiable?

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
end
