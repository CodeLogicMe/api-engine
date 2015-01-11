require_relative '../spec_helper'

module RestInMe
  RSpec.describe 'deleting an entity item' do
    include ::Rack::Test::Methods

    let(:ultra_pod) { create :app, :with_config }

    context 'for another app' do
      let(:new_app) { create :app }

      before do
        params = { name: 'RapaduraCast' }
        set_auth_headers_for!(ultra_pod, 'POST', params)
        post '/api/podcasts', params

        set_auth_headers_for!(new_app, 'DELETE', {})
        delete "/api/podcasts/#{last_json.id}"
      end

      it do
        expect(last_response.status).to eql 404
        expect(last_json.errors).to eql ['Not Found']
      end
    end

    context 'for the current app' do
      before do
        params = { name: 'RapaduraCast' }
        set_auth_headers_for!(ultra_pod, 'POST', params)
        post '/api/podcasts', params

        set_auth_headers_for!(ultra_pod, 'DELETE', {})
        delete "/api/podcasts/#{last_json.id}"
      end

      it do
        expect(last_response.status).to eql 204

        set_auth_headers_for!(ultra_pod, 'GET', {})
        get '/api/podcasts'
        expect(last_json.items.count).to eql 0
      end
    end
  end
end
