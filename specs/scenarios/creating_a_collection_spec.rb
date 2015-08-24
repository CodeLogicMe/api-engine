require_relative '../spec_helper'

RSpec.describe Frontend do
  include Rack::Test::Methods

  context 'with the required data' do
    let(:ultra_pod) { create :api }

    before do
      login_as ultra_pod.client
      post '/api/collections', {
        collection: { api: ultra_pod.id, name: 'users' }
      }
    end

    it 'should be possible' do
      expect(last_response.status).to eql 201
      expect(last_json.keys).to \
        match_array %w(collection fields)
      expect(last_json.collection.keys).to \
        match_array %w(id name fields)
    end
  end

  context 'without the required data' do
    let(:ultra_pod) { create :api }

    before do
      login_as ultra_pod.client
      post '/api/collections', {
        collection: { api: ultra_pod.id }
      }
    end

    it 'should not be possible' do
      expect(last_response.status).to eql 400
      expect(last_json.errors).to match_array [
        "Name can't be blank"
      ]
    end
  end
end
