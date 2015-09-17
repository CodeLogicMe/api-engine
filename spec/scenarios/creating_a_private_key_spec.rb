require 'spec_helper'

RSpec.describe Models::PrivateKey do
  context 'creating an api' do
    let(:api) { create :api }

    subject { described_class.create api: api }

    it { expect(subject.secret.length).to eq 64 }
  end
end

RSpec.describe Actions::NewPrivateKey do
  context 'creating an api' do
    let(:private_key) { create :private_key }

    subject do
      described_class.new(public_key: private_key.api.public_key)
    end

    it { expect(subject.call).to_not eq private_key }
  end
end
