require_relative "../spec_helper"

RSpec.describe API do
  include Rack::Test::Methods

  context "for the current app" do
    before do
      params = { name: "Nerdcast", episodes: 352 }
      ultra_pod = create :app, :with_config
      set_auth_headers_for!(ultra_pod, "POST", params)
      post "/api/podcasts", params
    end

    it "should create the resource" do
      expect(last_response.status).to eql 201
      expect(last_json.name).to eql "Nerdcast"
      expect(last_json.episodes).to eql 352
    end

    context "without require data" do
      before do
        ultra_pod = create :app, :with_config
        set_auth_headers_for!(ultra_pod, "POST", {})
        post "/api/podcasts", {}
      end

      it "should return validations errors" do
        expect(last_response.status).to eql 400
        expect(last_json.errors.length).to eql 2
        expect(last_json.errors).to match_array [
          "Name can't be blank", "Episodes can't be blank"
        ]
      end
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
