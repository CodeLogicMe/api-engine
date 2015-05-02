require_relative '../spec_helper'

module Actions
  RSpec.describe AuthenticateApp do
    let(:jedi_temple) { create :app }

    describe 'GETting' do
      context 'a valid key and secret' do
        let(:auth) do
          now_utc = Time.now.utc.to_i
          {
            timestamp: now_utc.to_s,
            public_key: jedi_temple.public_key,
            hmac: calculate_hmac('GET', jedi_temple.private_key.secret, {}, now_utc)
          }
        end
        let(:data) { { verb: 'GET', query_string: '', auth: auth } }

        subject { described_class.new(data) }

        it { expect(subject.call).to eq jedi_temple }
      end

      context 'a valid key but invalid secret' do
        now_utc = Time.now.utc
        let(:auth) do
          now_utc = Time.now.utc.to_i
          {
            timestamp: now_utc.to_s,
            public_key: jedi_temple.public_key,
            hmac: calculate_hmac('GET', 'super12345invalid09876secret1029384key', {}, now_utc)
          }
        end
        let(:data) { { verb: 'GET', query_string: '', auth: auth } }

        subject { described_class.new(data) }

        it do
          expect{ subject.call }
            .to raise_error AuthenticateApp::InvalidCredentials
        end
      end

      context 'an invalid key but valid secret' do
        let(:auth) do
          now_utc = Time.now.utc.to_i
          {
            timestamp: now_utc.to_s,
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
end

shared_examples 'as authenticable endpoint' do |verb, url, status|
  describe 'with a valid HMAC' do
    let(:dark_temple) { create :app }
    let(:private_key) { dark_temple.private_key.secret }
    let(:params) { { what: 'ever' } }

    before do
      timestamp = Time.now.utc.to_i
      header 'X-Request-Timestamp', timestamp.to_s
      header 'X-Access-Token', dark_temple.public_key
      header 'X-Request-Hash', calculate_hmac(verb.upcase, private_key, params, timestamp)

      public_send(verb.downcase, url, params)
    end

    it do
      expect(last_response.status).to eq status
      expect(last_json['app']).to eq dark_temple.name
    end
  end
end

RSpec.describe API do
  include Rack::Test::Methods

  it_behaves_like \
    'as authenticable endpoint',
    'GET',
    '/api/authenticate',
    200

  it_behaves_like \
    'as authenticable endpoint',
    'POST',
    '/api/authenticate',
    201

  it_behaves_like \
    'as authenticable endpoint',
    'PATCH',
    '/api/authenticate/some_id',
    200

  it_behaves_like \
    'as authenticable endpoint',
    'DELETE',
    '/api/authenticate/some_id',
    200
end
