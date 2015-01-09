require_relative '../spec_helper'

module RestInMe
  RSpec.describe Engines::EntityBuilder do
    include ::Rack::Test::Methods

    context 'for the current app' do
      let(:ultra_pod) { create :app, :with_config }

      before do
        10.times do |index|
          params = { name: "NerdCast-#{index}" }
          set_auth_headers_for!(ultra_pod, 'POST', params)
          post '/api/podcasts', params
        end
        set_auth_headers_for!(ultra_pod, 'GET', {})
        get '/api/podcasts'
      end

      it do
        expect(last_response.status).to eql 200
        expect(last_json['count']).to eql 10
        expect(last_json.items.last.keys).to eql %w(name created_at updated_at)
        expect(last_json.items.last.name).to eql 'NerdCast-9'
      end
    end
  end
end
