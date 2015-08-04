require_relative '../spec_helper'

RSpec.describe Models::Client do
  context 'given an non existant client' do
    subject do
      described_class.create \
        email: 'luke@jeditemple.org',
        password: '12345'
    end

    it 'should be possible' do
      expect(subject).to_not be_a_new_record
      expect(subject.email).to eq 'luke@jeditemple.org'
    end
  end

  context 'given an existant client' do
    subject do
      old_client = create :client
      described_class.create \
        email: old_client.email,
        password: '12345'
    end

    it 'should not be possible' do
      expect(subject).to be_a_new_record
    end
  end
end
