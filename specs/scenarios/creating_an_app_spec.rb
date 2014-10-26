require_relative '../spec_helper'

module Authk
  module Models
    RSpec.describe App do
      let(:client) { create :client }

      context 'creating an app' do
        subject { App.create name: 'Jedi Temple', client: client }

        it { expect(subject).to_not be_a_new_record }
        it { expect(subject.system_name).to eq 'jedi-temple' }
        it { expect(subject.public_key.length).to eq 64 }
        it { expect(subject.private_key).to_not be_a_new_record }
      end
    end
  end
end
