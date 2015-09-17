require 'spec_helper'

RSpec.describe Actions::ChangeApiTier do
  before do
    create(:tier, :free)
  end

  context 'with a previous tier' do
    let(:ultra_pod) { create(:api) }
    let(:tier) { create :tier, name: 'huge tier' }

    before do
      Timecop.travel(5.days.ago) { ultra_pod }

      described_class.new(api: ultra_pod, tier: tier).call
    end

    it "should set the new api's tier and deactivate the latter" do
      ultra_pod.reload.tap do |api|
        expect(api.tier).to eql tier
        expect(api.tier_usage.created_at).to be_within(1.day).of(Time.now)
        expect(api.tier_usages.first.deactivated_at).to be_within(1.day).of(Time.now)
        expect(api.tier_usage.deactivated_at).to be_nil
      end
    end
  end
end
