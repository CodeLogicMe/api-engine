require_relative '../spec_helper'

RSpec.describe Repositories::Entities do
  context 'an entity without fields' do
    let(:app) { create :app }

    subject { described_class.new(app: app) }

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
    let(:ultra_pod) { create :app }

    before do
      params = { id: ultra_pod.system_name, entity: { app: ultra_pod.system_name, name: 'users' } }
      set_auth_headers_for!(ultra_pod, 'POST', params)
      post '/entities', params
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
    let(:ultra_pod) { create :app }

    before do
      params = { id: ultra_pod.system_name, entity: { app: ultra_pod.system_name } }
      set_auth_headers_for!(ultra_pod, 'POST', params)
      post '/entities', params
    end

    it 'should not be possible' do
      expect(last_response.status).to eql 400
      expect(last_json.errors).to match_array [
        "Name can't be blank"
      ]
    end
  end
end
