require_relative '../spec_helper'

RSpec.describe API do
  include Rack::Test::Methods

  context 'when the quota in over' do
    let(:ultra_pod) do
      create :tier, :free
      create :api
    end

    before do
      allow_any_instance_of(Middlewares::Terminus::Quota)
        .to receive(:over?).and_return(true)
      set_auth_headers_for!(ultra_pod, 'GET', {})
      get '/podcasts'
    end

    it 'should not allow the request to go through' do
      expect(last_response.status).to eql 403
    end
  end

  context 'with enough quota available' do
    let(:ultra_pod) do
      create :tier, :free
      create :api, :podcast
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
    let(:success) { Rack::Response.new([], 200) }
    let(:rack_app) do
      double.tap do |dbl|
        allow(dbl).to receive(:call).and_return(success)
      end
    end

    before do
      allow_any_instance_of(described_class::Quota)
        .to receive(:over?).and_return(false)
      expect_any_instance_of(described_class::Quota)
        .to receive(:hit!)
    end

    subject { described_class.new(rack_app) }

    it 'should allow the request to go through' do
      expect(subject.call({}).status).to eql 200
      expect(rack_app).to have_received(:call)
    end
  end

  context 'when the app returns a 500' do
    let(:internal_error) { Rack::Response.new([], 500) }
    let(:rack_app) do
      double.tap do |dbl|
        allow(dbl).to receive(:call)
          .and_return(internal_error)
      end
    end

    before do
      allow_any_instance_of(described_class::Quota)
        .to receive(:over?).and_return(false)
      expect_any_instance_of(described_class::Quota)
        .to_not receive(:hit!)
    end

    subject { described_class.new(rack_app) }

    it 'should allow the request to go through' do
      expect(subject.call({}).status).to eql 500
      expect(rack_app).to have_received(:call)
    end
  end
end
