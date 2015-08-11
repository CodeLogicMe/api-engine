require_relative './timing'
require_relative '../../../business/workers/request_analyser'

module Veritas
  module Tracker
    extend self

    def call(env)
      timing = Timing.new

      yield.tap do |response|
        if success?(response.status)
          timing.finish!
          stat_request!(env['current_api'], response[0], timing, env)
        end
      end
    end

    private

    def success?(status)
      not [500, 401, 403].include?(status)
    end

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
  end
end
