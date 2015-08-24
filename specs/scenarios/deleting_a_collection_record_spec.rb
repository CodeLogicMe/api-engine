require_relative '../spec_helper'

RSpec.describe 'deleting a collection record' do
  include Rack::Test::Methods

  before do
    create :tier, :free
  end

  let(:ultra_pod) { create :api, :podcast }

  context 'for another api' do
    let(:new_api) { create :api }

    before do
      params = {
        data: {
          name: 'RapaduraCast',
          episodes: 40,
          website: 'rapadura-cast.com.br'
        }
      }
      set_auth_headers_for!(ultra_pod, 'POST', params)
      post '/engine/podcasts', params

      set_auth_headers_for!(new_api, 'DELETE', {})
      delete "/engine/podcasts/#{last_json.id}"
    end

    it do
      expect(last_response.status).to eql 404
      expect(last_json.errors).to eql ['Collection could not be found']
    end
  end

  context 'for the current api' do
    context 'with an existing record' do
      before do
        params = {
          data: {
            name: 'RapaduraCast',
            episodes: 30,
            website: 'rapadura-cast.com.br'
          }
        }
        set_auth_headers_for!(ultra_pod, 'POST', params)
        post '/engine/podcasts', params

        set_auth_headers_for!(ultra_pod, 'DELETE', {})
        delete "/engine/podcasts/#{last_json.id}"
      end

      it do
        expect(last_response.status).to eql 204

        set_auth_headers_for!(ultra_pod, 'GET', {})
        get '/engine/podcasts'
        expect(last_json.data.count).to eql 0
      end
    end

    context 'with an unexisting record' do
      before do
        set_auth_headers_for!(ultra_pod, 'DELETE', {})
        delete "/engine/podcasts/missingid"
      end

      it 'it should not be found' do
        expect(last_response.status).to eql 404
        expect(last_json.errors).to match_array [
          'Record not found'
        ]
      end
    end
  end
end
