require_relative '../spec_helper'

RSpec.describe API do
  include Rack::Test::Methods

  context 'for the current app' do
    before do
      params = { data: { name: 'Nerdcast', episodes: 352, website_url: 'jovemnerd.com.br' } }
      ultra_pod = create :app, :with_config
      set_auth_headers_for!(ultra_pod, 'POST', params)
      post '/api/podcasts', params
    end

    it 'should create the resource' do
      expect(last_response.status).to eql 201
      expect(last_json.name).to eql 'Nerdcast'
      expect(last_json.episodes).to eql '352.0'
    end

    context 'without the required data' do
      before do
        mega_pod = create :app, :with_config
        set_auth_headers_for!(mega_pod, 'POST', {})
        post '/api/podcasts', {}
      end

      it 'should return validations errors' do
        expect(last_response.status).to eql 400
        expect(last_json.errors).to match_array [
          "Name can't be blank",
          "Episodes can't be blank",
          "Website_url can't be blank"
        ]
      end
    end

    context 'with duplicate data' do
      before do
        params = { data: { name: 'Nerdcast', episodes: 352, website_url: 'jovemnerd.com.br' } }
        ultra_pod = create :app, :with_config

        2.times do
          set_auth_headers_for!(ultra_pod, 'POST', params)
          post '/api/podcasts', params
        end
      end

      it 'should not add the second' do
        expect(last_response.status).to eql 400
        expect(last_json.errors).to match_array [
          'Name already exists', 'Website_url already exists'
        ]
      end
    end
  end

  context 'for another app' do
    before do
      create :app, :with_config
      set_auth_headers_for!(create(:app), 'POST', {})
      post '/api/podcasts', {}
    end

    it 'should not be found' do
      expect(last_response.status).to eql 404
    end
  end
end
