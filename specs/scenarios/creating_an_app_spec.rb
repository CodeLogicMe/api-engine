require_relative '../spec_helper'

module Authentik
  module Models
    RSpec.describe App do
      context 'creating an app' do
        subject { App.create name: 'Jedi Temple' }

        it { expect(subject).to_not be_a_new_record }
        it { expect(subject.system_name).to eq 'jedi-temple' }
        it { expect(subject.public_key.length).to eq 64 }
      end
    end
  end

  module Actions
    RSpec.describe CreateApp do
      context 'creating an app' do
        let(:params) { { name: 'Dark Temple' } }

        subject { CreateApp.new(params) }

        it { expect(subject.call).to be_a Models::App }
        it { expect(subject.call).to_not be_a_new_record }
        it { expect(subject.call.name).to eq 'Dark Temple' }
      end
    end
  end
end
