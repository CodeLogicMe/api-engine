require_relative '../spec_helper'

RSpec.describe Repositories::Fields, 'creating a field' do
  context 'a duplicate field' do
    let(:api) { create :api, :with_config }
    let(:entity) { api.api_config.entities.first }
    let(:field) { entity[:fields].first }

    subject do
      described_class.new(api: api, entity: entity)
    end

    it 'should not be allowed' do
      validations = subject.add field
      expect(validations).to_not be_ok
    end
  end
end

RSpec.describe Frontend, 'creating a field' do
  include Rack::Test::Methods

  context 'with a unique set of data' do
    let(:ultra_pod) { create :api, :with_config }
    let(:entity) { ultra_pod.api_config.entities.first }

    before do
      login_as ultra_pod.client
      post '/api/fields', {
        field: {
          entity: "#{ultra_pod.system_name}#podcasts",
          name: 'number',
          type: 'number',
          validates: ['presence']
        }
      }
    end

    it 'should be able to create it' do
      expect(last_response.status).to eql 201
      expect(last_json.field.keys).to match_array %w(
        id name type validates internal entity
      )
    end
  end

  context 'with an a duplicate set of data' do
    let(:ultra_pod) { create :api, :with_config }
    let(:entity) { ultra_pod.api_config.entities.first }

    before do
      login_as ultra_pod.client

      2.times {
        post '/api/fields', {
          field: {
            entity: "#{ultra_pod.system_name}#podcasts",
            name: 'number',
            type: 'number',
            validates: ['presence']
          }
        }
      }
    end

    it 'should not be able to create it' do
      expect(last_response.status).to eql 400
      expect(last_json.errors).to match_array [
        'Name already exists'
      ]
    end
  end
end
