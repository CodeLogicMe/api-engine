require_relative '../spec_helper'

RSpec.describe API do
  include Rack::Test::Methods

  context 'when the quota in over' do
    let(:ultra_pod) do
      create :api, :with_config, tier: create(:tier, :prototype)
    end

    before do
      allow_any_instance_of(Middlewares::Terminus::Quota).to receive(:hit_count).and_return(1001)
      set_auth_headers_for!(ultra_pod, 'GET', {})
      get '/podcasts'
    end

    it 'should not allow the request to go through' do
      expect(last_response.status).to eql 403
    end
  end

  context 'with enough quota available' do
    let(:ultra_pod) do
      create :api, :with_config, tier: create(:tier, :prototype)
    end

    before do
      set_auth_headers_for!(ultra_pod, 'GET', {})
      get '/podcasts'
    end

    it 'should allow the request to go through' do
      expect(last_response.status).to eql 200
    end
  end
end
