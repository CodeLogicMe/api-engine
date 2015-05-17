require_relative '../spec_helper'

RSpec.describe API do
  include Rack::Test::Methods

  context 'when the quota in over' do
    let(:ultra_pod) do
      create :api, :with_config, tier: create(:tier, :prototype)
    end

    before do
      allow_any_instance_of(Middlewares::Terminus::Quota).to receive(:over?).and_return(true)
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

RSpec.describe Middlewares::Terminus do
  context 'when quota is over' do
    let(:rack_app) do
      double.tap do |dbl|
        allow(dbl).to receive(:call).and_return([200])
      end
    end

    before do
      allow_any_instance_of(described_class::Quota).to receive(:over?).and_return(true)
    end

    subject { described_class.new(rack_app) }

    it 'should not allow the request to go through' do
      expect(subject.call({})[0]).to eql 403
      expect(rack_app).to_not have_received(:call)
    end
  end

  context 'when there is enough quota' do
    let(:rack_app) do
      double.tap do |dbl|
        allow(dbl).to receive(:call).and_return([200])
      end
    end

    before do
      allow_any_instance_of(described_class::Quota).to receive(:over?).and_return(false)
      expect_any_instance_of(described_class::Quota).to receive(:hit!)
    end

    subject { described_class.new(rack_app) }

    it 'should allow the request to go through' do
      expect(subject.call({})[0]).to eql 200
      expect(rack_app).to have_received(:call)
    end
  end

  context 'when the app returns a 500' do
    let(:rack_app) do
      double.tap do |dbl|
        allow(dbl).to receive(:call).and_return([500])
      end
    end

    before do
      allow_any_instance_of(described_class::Quota).to receive(:over?).and_return(false)
      expect_any_instance_of(described_class::Quota).to_not receive(:hit!)
    end

    subject { described_class.new(rack_app) }

    it 'should allow the request to go through' do
      expect(subject.call({})[0]).to eql 500
      expect(rack_app).to have_received(:call)
    end
  end
end
