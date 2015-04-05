require_relative '../spec_helper'

RSpec.describe Models::App do
  let(:client) { create :client }

  context 'creating an app' do
    subject { described_class.create name: 'Jedi Temple', client: client }

    it { expect(subject).to_not be_a_new_record }
    it { expect(subject.system_name).to eq 'jedi-temple' }
    it { expect(subject.public_key.length).to eq 64 }
    it { expect(subject.private_key).to_not be_a_new_record }
  end
end
