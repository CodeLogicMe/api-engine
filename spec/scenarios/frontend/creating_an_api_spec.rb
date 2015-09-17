require 'spec_helper'

RSpec.describe Models::Api do
  let(:client) { create :client }

  before do
    create :tier, :free
  end

  context 'creating an api' do
    subject { described_class.create name: 'Jedi Temple', client: client }

    it do
      subject.tap do |api|
        expect(api).to_not be_a_new_record
        expect(api.system_name).to eq 'jedi-temple'
        expect(api.public_key.length).to eq 64
        expect(api.private_key).to_not be_a_new_record
        expect(api.tier).to be_free
      end
    end
  end
end
