require_relative '../spec_helper'

module Authentik
  module Actions
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

  RSpec.describe API do
    include ::Rack::Test::Methods

    describe 'with the correct data' do
      let(:client) { create :client }
      let(:dark_temple) do
        Actions::CreateApp.new(
          client_id: client.id, name: 'Dark Temple'
        ).call
      end

      before do
        post '/api/authenticate',
          public_key: dark_temple.public_key,
          private_key: dark_temple.private_key.secret
      end

      it { expect(last_response.status).to eq 202 }
      it { expect(last_json["result"]).to eq 'ready to rumble!!!' }
    end
  end
end
