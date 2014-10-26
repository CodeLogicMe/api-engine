require_relative '../spec_helper'

module Authk
  RSpec.describe API do
    include ::Rack::Test::Methods

    let(:dark_temple) { create :app }

    before do
      create_list :user, 5, app: dark_temple
    end

    describe 'for the current app' do
      before do
        set_auth_headers_for!(dark_temple, 'GET', {})
        get '/api/users', {}
      end

      it { expect(last_response.status).to eq 200 }
      it { expect(last_json["total"]).to eq 5 }
    end

    describe 'with an app that has no users' do
      let(:ligth_temple) { create :app }

      before do
        set_auth_headers_for!(ligth_temple, 'GET', {})
        get '/api/users', {}
      end

      it { expect(last_response.status).to eq 200 }
      it { expect(last_json["total"]).to eq 0 }
    end
  end
end
