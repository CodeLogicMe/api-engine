require_relative '../spec_helper'

RSpec.describe Frontend, 'creating a field' do
  include Rack::Test::Methods

  context 'with a unique set of data' do
    let(:ultra_pod) { create :api, :podcast }
    let(:collection) { ultra_pod.collections.first }

    before do
      login_as ultra_pod.client

      post '/api/fields', {
        field: {
          collection: collection.id,
          name: 'episode_number',
          type: 'number',
          validations: ['presence']
        }
      }
    end

    it 'should be able to create it' do
      expect(last_response.status).to eql 201
      expect(last_json.field.keys).to match_array %w(
        id name type validations internal collection
      )
    end
  end

  context 'with a duplicate set of data' do
    let(:ultra_pod) { create :api, :podcast }
    let(:collection) { ultra_pod.collections.first }

    before do
      login_as ultra_pod.client

      2.times {
        post '/api/fields', {
          field: {
            collection: collection.id,
            name: 'number',
            type: 'number',
            validations: ['presence']
          }
        }
      }
    end

    it 'should not be able to create it' do
      expect(last_response.status).to eql 400
      expect(last_json.errors).to match_array [
        'Name has already been taken'
      ]
    end
  end
end
