require_relative '../spec_helper'

RSpec.describe Repositories::Entities do
  context 'an entity without fields' do
    let(:api) { create :api }

    subject { described_class.new(api: api) }

    before do
      subject.add(name: 'users')
    end

    it 'should add all internal fields' do
      fields = subject.all.first[:fields]

      expect(fields.map {|field| field['name']})
        .to match_array %w(id created_at updated_at)
    end
  end
end

RSpec.describe Frontend do
  include Rack::Test::Methods

  context 'with the required data' do
    let(:ultra_pod) { create :api }

    before do
      login_as ultra_pod.client
      post '/api/entities', { id: ultra_pod.system_name, entity: {
        api: ultra_pod.system_name, name: 'users' }
      }
    end

    it 'should be possible' do
      expect(last_response.status).to eql 201
      expect(last_json.keys).to match_array %w(entity fields)
      expect(last_json.entity.keys).to match_array %w(
        id name fields
      )
    end
  end

  context 'without the required data' do
    let(:ultra_pod) { create :api }

    before do
      login_as ultra_pod.client
      post '/api/entities', { id: ultra_pod.system_name, entity: {
        api: ultra_pod.system_name }
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
