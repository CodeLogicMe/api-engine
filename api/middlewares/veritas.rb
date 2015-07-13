require_relative '../../business/workers/request_analyser'

module Middlewares
  class Veritas
    def initialize(app)
      @app = app
    end

    def call(env)
      timing = Timing.new

      response = @app.call env

      unless [500, 401, 403].include?(response[0])
        timing.finish!
        stat_request!(env['current_api'], response[0], timing, env)
      end

      response
    end

    private

    def stat_request!(current_api, status, timing, env)
      relevant_info = {
        ip_address: env['REMOTE_ADDR'],
        language: env['HTTP_ACCEPT_LANGUAGE'],
        user_agent: env['HTTP_USER_AGENT'],
        status: status
      }.merge(timing.to_h)

      enqueue_for_analysis current_api, relevant_info
    end

    def enqueue_for_analysis(current_api, info)
      Workers::RequestAnalyser.perform_async \
        current_api.id.to_s, info
    end

    class Timing
      attr_reader :started_at, :ended_at, :duration

      def initialize
        @started_at = Time.now.utc
      end

      def finish!
        @ended_at = Time.now.utc
        @duration = @ended_at - @started_at
      end

      def to_h
        {
          started_at: started_at,
          ended_at: ended_at,
          duration: duration
        }
      end
    end
  end
end
