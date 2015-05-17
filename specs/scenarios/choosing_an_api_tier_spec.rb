require_relative '../spec_helper'

RSpec.describe Actions::ChangeApiTier do
  context 'without a previous tier' do
    let(:ultra_pod) { create :api }
    let(:tier) { create :tier, name: 'huge tier' }

    before do
      described_class.new(api: ultra_pod, tier: tier).call
    end

    it "should set the api's tier" do
      expect(ultra_pod.tier).to eql tier
      expect(ultra_pod.tier_usage.deactivated_at).to be_nil
    end
  end

  context 'with a previous tier' do
    let(:ultra_pod) do
      create(:api).tap do |api|
        create :tier_usage, api: api
      end
    end
    let(:tier) { create :tier, name: 'huge tier' }

    before do
      Timecop.travel 5.days.ago do
        ultra_pod
      end

      described_class.new(api: ultra_pod, tier: tier).call
    end

    it "should set the new api's tier" do
      expect(ultra_pod.tier).to eql tier
      expect(ultra_pod.tier_usage.created_at).to be_within(1.day).of(Time.now)
      expect(ultra_pod.tier_usages.first.deactivated_at).to be_within(1.day).of(Time.now)
      expect(ultra_pod.tier_usage.deactivated_at).to be_nil
    end
  end
end
