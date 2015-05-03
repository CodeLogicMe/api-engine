require_relative '../spec_helper'

RSpec.describe Repositories::Fields do
  context 'a duplicate field' do
    let(:app) { create :app, :with_config }
    let(:entity) { app.app_config.entities.first }
    let(:field) { entity[:fields].first }

    subject do
      described_class.new(app: app, entity: entity)
    end

    it 'should not be allowed' do
      validations = subject.add field
      expect(validations).to_not be_ok
    end
  end
end

RSpec.describe Frontend do
  include Rack::Test::Methods

  context 'with a new field' do
    before do
      params = { field: { name: 'number', type: 'number', validates: ['presence'] } }
      ultra_pod = create :app, :with_config
      set_auth_headers_for!(ultra_pod, "POST", params)
      post '/fields', params
    end

    it 'spec_name' do
      p last_json
      expect(last_response.status).to eql 201
      expect(last_json.keys).to match_array [
        :id
      ]
    end
  end
end
