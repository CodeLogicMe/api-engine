require 'spec_helper'

RSpec.describe API do
  include Rack::Test::Methods

  context 'when the quota in over' do
    let(:ultra_pod) do
      create :tier, :free
      create :api
    end

    before do
      allow_any_instance_of(Terminus::Quota)
        .to receive(:over?).and_return(true)
      set_auth_headers_for!(ultra_pod, 'GET', {})
      get '/engine/podcasts'
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
      get '/engine/podcasts'
    end

    it 'should allow the request to go through' do
      expect(last_response.status).to eql 200
    end
  end
end

module Terminus
  RSpec.describe Middleware do
    context 'when quota is over' do
      let(:rack_app) do
        double.tap do |dbl|
          allow(dbl).to receive(:call).and_return([200])
        end
      end

      before do
        allow_any_instance_of(Quota).to receive(:over?).and_return(true)
      end

      subject { described_class.new(rack_app) }

      it 'should not allow the request to go through' do
        expect(subject.call({}).status).to eql 403
        expect(rack_app).to_not have_received(:call)
      end
    end

    context 'when there is enough quota' do
      let(:success) { Rack::Response.new({}, 200) }
      let(:rack_app) do
        double.tap do |dbl|
          allow(dbl).to receive(:call).and_return(success)
        end
      end
      let(:env) { { 'current_api' => double(:api, id: 1) } }

      before do
        allow_any_instance_of(Quota)
          .to receive(:over?).and_return(false)
        allow(Quota::STORE).to receive(:incr)
      end

      subject { described_class.new(rack_app) }

      it 'should allow the request to go through' do
        expect(subject.call(env).status).to eql 200
        expect(rack_app).to have_received(:call)
      end
    end

    context 'when the app returns a 500' do
      let(:internal_error) { Rack::Response.new({}, 500) }
      let(:rack_app) do
        double.tap do |dbl|
          allow(dbl).to receive(:call)
            .and_return(internal_error)
        end
      end

      before do
        allow_any_instance_of(Quota)
          .to receive(:over?).and_return(false)
        allow(Quota::STORE).to receive(:incr)
      end

      subject { described_class.new(rack_app) }

      it 'should allow the request to go through' do
        expect(subject.call({}).status).to eql 500
        expect(rack_app).to have_received(:call)
      end
    end
  end
end
