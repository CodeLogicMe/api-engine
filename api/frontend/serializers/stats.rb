require_relative '../../engine/terminus/quota'

module Serializers
  class Stats
    def initialize(api)
      @api = api
    end

    def to_h
      {
        id: 'nevermind',
        quota: {
          current: Terminus::Quota.new(@api).hit_count,
          max: @api.tier.quota
        }
      }
    end
  end
end
