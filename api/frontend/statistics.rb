require 'grape'
require_relative 'auth_helpers'
require_relative 'serializers/stats'

module Frontend
  class Statistics < Grape::API
    helpers AuthHelpers

    get '/statistics/:api_id' do
      authenticate!
      api = current_client.apis.find(params.api_id)
      { statistic: Serializers::Stats.new(api).to_h }
    end
  end
end
