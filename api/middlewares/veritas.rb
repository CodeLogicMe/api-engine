require_relative '../../business/workers/request_analyser'

module Middlewares
  class Veritas < Grape::Middleware::Base
    def initialize(app)
      @app = app
    end

    def call(env)
      response = @app.call env

      if response[0].to_s !~ /5\d{2}/
        stat_request!(env)
      end

      response
    end

    private

    def stat_request!(request)
      request = Rack::Request.new(env)

      relevant_info = {
        ip_address: request.ip,
        language: env['HTTP_ACCEPT_LANGUAGE'],
        user_agent: request.user_agent
      }

      enqueue_for_processing relevant_info
    end

    def enqueue_for_processing(info)
      return if info[:ip] == '127.0.0.1'

      Workers::RequestAnalyser.perform_async info
    end
  end
end
