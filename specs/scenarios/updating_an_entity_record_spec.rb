require_relative '../spec_helper'

RSpec.describe API, 'updating an entity record' do
  include Rack::Test::Methods

  context 'Updating' do
    context 'a non existant record' do
      before do
        ultra_pod = create :app, :with_config
        set_auth_headers_for!(ultra_pod, 'PUT', {})
        put '/podcasts/123invalid456ID'
      end

      it 'should not be possible' do
        expect(last_response.status).to eql 404
        expect(last_json.errors).to eql ['Record not found']
      end
    end

    context 'an existing record' do
      before do
        params = { data: { name: 'Nerdcast', episodes: 362, website_url: 'jovermnerd.com.br' } }
        ultra_pod = create :app, :with_config

        set_auth_headers_for!(ultra_pod, 'POST', params)
        post '/podcasts/', params

        new_params = { data: { name: 'NerdCast' } }
        set_auth_headers_for!(ultra_pod, 'PUT', new_params)
        put "/podcasts/#{last_json.id}", new_params
      end

      it 'should be possible' do
        expect(last_response.status).to eql 200
        expect(last_json.name).to eql 'NerdCast'
      end
    end
  end
end
