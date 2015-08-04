require_relative '../spec_helper'

module Actions
  RSpec.describe AuthenticateApi, 'testing the authentication engine' do
    let(:jedi_temple) { create :api }

    describe 'GETting' do
      context 'a valid key and secret' do
        let(:auth) do
          now_utc = Time.now.utc.to_i
          {
            timestamp: now_utc.to_s,
            public_key: jedi_temple.public_key,
            hash: calculate_hmac('GET', jedi_temple.private_key.secret, {}, now_utc)
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
            hash: calculate_hmac('GET', 'super12345invalid09876secret1029384key', {}, now_utc)
          }
        end
        let(:data) { { verb: 'GET', query_string: '', auth: auth } }

        subject { described_class.new(data) }

        it do
          expect{ subject.call }
            .to raise_error AuthenticateApi::InvalidCredentials
        end
      end

      context 'an invalid key but valid secret' do
        let(:auth) do
          now_utc = Time.now.utc.to_i
          {
            timestamp: now_utc.to_s,
            public_key: 'super12345invalid09876secret1029384key',
            hash: calculate_hmac('GET', jedi_temple.private_key.secret, {}, now_utc)
          }
        end
        let(:data) { { verb: 'GET', query_string: '', auth: auth } }

        subject { described_class.new(data) }

        it { expect{subject.call}.to raise_error ActiveRecord::RecordNotFound }
      end
    end
  end
end

shared_examples 'an authenticable endpoint' do |verb, url, status|
  before do
    create(:tier, :free)
  end

  context 'that given an invalid access token' do
    before do
      header 'X-Request-Timestamp', '9999999999'
      header 'X-Access-Token', 'anonexistantpublickey'
      header 'X-Request-Hash', 'arandomultrahugehash'

      public_send verb.downcase, url, {}
    end

    it 'should refute the API request' do
      expect(last_response.status).to eql 404
    end
  end

  context 'that given an invalid request hash' do
    let(:ultra_pod) { create :api }

    before do
      header 'X-Request-Timestamp', '9999999999'
      header 'X-Access-Token', ultra_pod.public_key
      header 'X-Request-Hash', 'arandomultrahugehash'

      public_send verb.downcase, url, {}
    end

    it 'should refute the API request' do
      expect(last_response.status).to eql 401
    end
  end

  context 'that given valid auth headers' do
    let(:ultra_pod) { create :api }
    let(:private_key) { ultra_pod.private_key.secret }
    let(:params) { { what: 'ever' } }

    before do
      timestamp = Time.now.utc.to_i
      header 'X-Request-Timestamp', timestamp.to_s
      header 'X-Access-Token', ultra_pod.public_key
      header 'X-Request-Hash', calculate_hmac(verb.upcase, private_key, params, timestamp)

      public_send(verb.downcase, url, params)
    end

    it 'should accept the API request' do
      expect(last_response.status).to eq status
      expect(last_json['api']).to eq ultra_pod.name
    end
  end
end

RSpec.describe API do
  include Rack::Test::Methods

  it_behaves_like \
    'an authenticable endpoint',
    'GET',
    '/engine/authenticate',
    200

  it_behaves_like \
    'an authenticable endpoint',
    'POST',
    '/engine/authenticate',
    201

  it_behaves_like \
    'an authenticable endpoint',
    'PUT',
    '/engine/authenticate/some_id',
    200

  it_behaves_like \
    'an authenticable endpoint',
    'DELETE',
    '/engine/authenticate/some_id',
    200
end
