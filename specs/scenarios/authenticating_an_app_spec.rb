require_relative '../spec_helper'

module Authk
  module Actions
    RSpec.describe AuthenticateApp do
      let(:jedi_temple) { create :app }

      context 'a valid key and secret' do
        let(:auth) do
          now_utc = Time.now.utc
          {
            timestamp: now_utc,
            public_key: jedi_temple.public_key,
            hmac: calculate_hmac('GET', jedi_temple.private_key.secret, {}, now_utc)
          }
        end
        let(:data) { { verb: 'GET', query_string: '', auth: auth } }

        subject { AuthenticateApp.new(data) }

        it { expect(subject.call).to eq jedi_temple }
      end

      context 'a valid key but invalid secret' do
        now_utc = Time.now.utc
        let(:auth) do
          now_utc = Time.now.utc
          {
            timestamp: now_utc,
            public_key: jedi_temple.public_key,
            hmac: calculate_hmac('GET', 'super12345invalid09876secret1029384key', {}, now_utc)
          }
        end
        let(:data) { { verb: 'GET', query_string: '', auth: auth } }

        subject { AuthenticateApp.new(data) }

        it { expect{subject.call}.to raise_error AuthenticateApp::InvalidCredentials }
      end

      context 'an invalid key but valid secret' do
        let(:auth) do
          now_utc = Time.now.utc
          {
            timestamp: now_utc,
            public_key: 'super12345invalid09876secret1029384key',
            hmac: calculate_hmac('GET', jedi_temple.private_key.secret, {}, now_utc)
          }
        end
        let(:data) { { verb: 'GET', query_string: '', auth: auth } }

        subject { AuthenticateApp.new(data) }

        it { expect{subject.call}.to raise_error Mongoid::Errors::DocumentNotFound }
      end
    end
  end

  RSpec.describe API do
    include ::Rack::Test::Methods

    describe 'with a valid HMAC' do
      let(:dark_temple) { create :app }
      let(:private_key) { dark_temple.private_key.secret }
      let(:params) { { what: 'ever' } }

      before do
        timestamp = Time.now.utc
        header 'Timestamp', timestamp
        header 'PublicKey', dark_temple.public_key
        header 'Hmac', calculate_hmac('GET', private_key, params, timestamp)
        get '/api/authenticate', params
      end

      it { expect(last_response.status).to eq 200 }
      it { expect(last_json["app"]).to eq dark_temple.name }
    end
  end
end
