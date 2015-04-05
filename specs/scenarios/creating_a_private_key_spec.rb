require_relative '../spec_helper'

RSpec.describe Models::PrivateKey do
  context 'creating an app' do
    let(:app) { create :app }

    subject { described_class.create app: app }

    it { expect(subject.secret.length).to eq 64 }
  end
end

RSpec.describe Actions::NewPrivateKey do
  context 'creating an app' do
    let(:private_key) { create :private_key }

    subject do
      described_class.new(public_key: private_key.app.public_key)
    end

    it { expect(subject.call).to_not eq private_key }
  end
end
