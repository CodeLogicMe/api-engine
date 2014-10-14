require_relative '../spec_helper'

module Authentik::Models
  RSpec.describe App do
    context 'creating an app' do
      subject do
        App.create \
          name: 'Jedi Temple',
          password: '12345'
      end

      it { expect(subject).to_not be_a_new_record }
      it { expect(subject.system_name).to eq 'jedi-temple' }
      it { expect(subject.password_checks?(12345)).to eq true }
    end
  end
end
