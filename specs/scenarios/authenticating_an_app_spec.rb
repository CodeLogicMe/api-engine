require_relative '../spec_helper'

module Authentik::Actions
  RSpec.describe AuthenticateApp do
    let(:client) { create :client }
    let(:app) do
      CreateApp.new(client_id: client.id, name: 'Jedi Temple').call
    end

    context 'a valid key and secret' do
      let(:params) do
        {
          public_key: app.public_key,
          private_key: app.private_key.secret
        }
      end

      subject { AuthenticateApp.new(params) }

      it { expect(subject.call).to eq app }
    end

    context 'a valid key but invalid secret' do
      let(:params) do
        {
          public_key: app.public_key,
          private_key: 'super12345invalid09876secret1029384key'
        }
      end

      subject { AuthenticateApp.new(params) }

      it { expect{subject.call}.to raise_error Mongoid::Errors::DocumentNotFound }
    end

    context 'an invalid key but valid secret' do
      let(:params) do
        {
          public_key: 'super12345invalid09876secret1029384key',
          private_key: app.private_key.secret
        }
      end

      subject { AuthenticateApp.new(params) }

      it { expect{subject.call}.to raise_error Mongoid::Errors::DocumentNotFound }
    end
  end
end
