require_relative '../spec_helper'

module RestInMe::Models
  RSpec.describe PrivateKey do
    context 'creating an app' do
      let(:app) { create :app }

      subject { PrivateKey.create app: app }

      it { expect(subject.secret.length).to eq 64 }
    end
  end
end

module RestInMe::Actions
  RSpec.describe NewPrivateKey do
    context 'creating an app' do
      let(:private_key) { create :private_key }

      subject { NewPrivateKey.new(public_key: private_key.app.public_key) }

      it { expect(subject.call).to_not eq private_key }
    end
  end
end
