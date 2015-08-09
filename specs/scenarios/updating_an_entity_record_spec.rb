require_relative '../spec_helper'

RSpec.describe API, 'updating an entity record' do
  include Rack::Test::Methods

  before { create :tier, :free }

  context 'Updating' do
    context 'a non existant record' do
      before do
        ultra_pod = create :api, :podcast
        set_auth_headers_for!(ultra_pod, 'PUT', {})
        put '/engine/podcasts/123invalid456ID'
      end

      it 'should not be possible' do
        expect(last_response.status).to eql 404
        expect(last_json.errors).to eql ['Record not found']
      end
    end

    context 'an existing record' do
      before do
        params = {
          data: {
            name: 'Nerdcast',
            episodes: 362,
            website: 'jovermnerd.com.br'
          }
        }
        ultra_pod = create :api, :podcast

        set_auth_headers_for!(ultra_pod, 'POST', params)
        post '/engine/podcasts/', params

        new_params = { data: { name: 'NerdCast' } }
        set_auth_headers_for!(ultra_pod, 'PUT', new_params)
        put "/engine/podcasts/#{last_json.id}", new_params
      end

      it 'should be possible' do
        expect(last_response.status).to eql 200
        expect(last_json.name).to eql 'NerdCast'
      end
    end
  end
end
