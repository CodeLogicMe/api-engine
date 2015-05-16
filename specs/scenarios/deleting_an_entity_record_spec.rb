require_relative '../spec_helper'

RSpec.describe 'deleting an entity record' do
  include Rack::Test::Methods

  let(:ultra_pod) { create :api, :with_config }

  context 'for another api' do
    let(:new_api) { create :api }

    before do
      params = { data: { name: 'RapaduraCast', episodes: 40, website_url: 'rapadura-cast.com.br' } }
      set_auth_headers_for!(ultra_pod, 'POST', params)
      post '/podcasts', params

      set_auth_headers_for!(new_api, 'DELETE', {})
      delete "/podcasts/#{last_json.id}"
    end

    it do
      expect(last_response.status).to eql 404
      expect(last_json.errors).to eql ['Not Found']
    end
  end

  context 'for the current api' do
    before do
      params = { data: { name: 'RapaduraCast', episodes: 30, website_url: 'rapadura-cast.com.br' } }
      set_auth_headers_for!(ultra_pod, 'POST', params)
      post '/podcasts', params

      set_auth_headers_for!(ultra_pod, 'DELETE', {})
      delete "/podcasts/#{last_json.id}"
    end

    it do
      expect(last_response.status).to eql 204

      set_auth_headers_for!(ultra_pod, 'GET', {})
      get '/podcasts'
      expect(last_json.items.count).to eql 0
    end
  end
end
