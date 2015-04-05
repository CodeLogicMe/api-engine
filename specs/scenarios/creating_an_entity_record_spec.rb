require_relative '../spec_helper'

RSpec.describe API do
  include Rack::Test::Methods

  context 'for the current app' do
    let(:params) { { name: 'Nerdcast', episodes: 352 } }

    before do
      ultra_pod = create :app, :with_config
      set_auth_headers_for!(ultra_pod, 'POST', params)
      post '/api/podcasts', params
    end

    it do
      expect(last_response.status).to eql 201
      expect(last_json.name).to eql 'Nerdcast'
      expect(last_json.episodes).to eql 352
    end
  end
end
