require_relative '../spec_helper'

RSpec.describe Models::Api do
  let(:client) { create :client }

  before do
    create :tier, :prototype
  end

  context 'creating an api' do
    subject { described_class.create name: 'Jedi Temple', client: client }

    it { expect(subject).to_not be_a_new_record }
    it { expect(subject.system_name).to eq 'jedi-temple' }
    it { expect(subject.public_key.length).to eq 64 }
    it { expect(subject.private_key).to_not be_a_new_record }
  end
end
