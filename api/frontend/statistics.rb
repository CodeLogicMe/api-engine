require 'grape'
require_relative 'auth_helpers'

module Frontend
  class Statistics < Grape::API
    helpers AuthHelpers

    before { authenticate! }

    get '/statistics/:api_id' do
      authenticate!
      api = current_client.apis.find_by(system_name: params.api_id)
      { statistic: Serializers::Stats.new(api).to_h }
    end
  end
end
