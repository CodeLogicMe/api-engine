require_relative '../spec_helper'

RSpec.describe API do
  include Rack::Test::Methods

  context 'for the current app' do
    before do
      params = { name: 'Nerdcast', episodes: 352 }
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

  context "for another app" do
    before do
      create :app, :with_config
      set_auth_headers_for!(create(:app), "POST", {})
      post "/api/podcasts", {}
    end

    it "should not be found" do
      expect(last_response.status).to eql 404
    end
  end
end
