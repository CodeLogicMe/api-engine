require_relative '../spec_helper'

module Authentik::Models
  RSpec.describe User do
    context 'creating an app' do
      let(:jedi_temple) { create :app }

      subject do
        User.create \
          app: jedi_temple,
          email: 'luke@jeditemple.org',
          password: '54321'
      end

      it { expect(subject).to_not be_a_new_record }
      it { expect(subject.password_checks?(54321)).to eq true }
      it { expect(subject).to eq jedi_temple.users.first }
    end
  end
end
