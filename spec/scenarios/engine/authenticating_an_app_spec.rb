require 'spec_helper'

RSpec.shared_examples 'an authenticable endpoint' do |verb, url, status|
  include Rack::Test::Methods

  before do
    create(:tier, :free)
  end

  describe "when #{verb.upcase}ing" do
    context 'without a public key' do
      before do
        public_send verb.downcase, url, {}
      end

      it 'should refute the API request' do
        expect(last_response).to not_be_found
      end
    end

    context 'with an invalid authentication data' do
      before do
        header 'X-Request-Timestamp', '9999999999'
        header 'X-Access-Token', 'anonexistantpublickey'
        header 'X-Request-Hash', 'arandomultrahugehash'

        public_send verb.downcase, url, {}
      end

      it 'should refute the API request' do
        expect(last_response).to not_be_found
      end
    end

    context 'with an invalid request hash and timestamp' do
      let(:ultra_pod) { create :api }

      before do
        header 'X-Request-Timestamp', '9999999999'
        header 'X-Access-Token', ultra_pod.public_key
        header 'X-Request-Hash', 'arandomultrahugehash'

        public_send verb.downcase, url, {}
      end

      it 'should refute the API request' do
        expect(last_response).to be_unauthorized
      end
    end

    context 'with an invalid access token' do
      let(:ultra_pod) { create :api }
      let(:private_key) { ultra_pod.private_key.secret }
      let(:params) { { what: 'ever' } }

      before do
        timestamp = Time.now.utc.to_i
        header 'X-Request-Timestamp', timestamp.to_s
        header 'X-Access-Token', 'anonexistantpublickey'
        header 'X-Request-Hash', calculate_hmac(verb.upcase, private_key, params, timestamp)

        public_send verb.downcase, url, {}
      end

      it 'should refute the API request' do
        expect(last_response).to not_be_found
      end
    end

    context 'with an invalid request hash' do
      let(:ultra_pod) { create :api }

      before do
        timestamp = Time.now.utc.to_i
        header 'X-Request-Timestamp', timestamp.to_s
        header 'X-Access-Token', ultra_pod.public_key
        header 'X-Request-Hash', 'arandomultrahugehash'

        public_send verb.downcase, url, {}
      end

      it 'should refute the API request' do
        expect(last_response).to be_unauthorized
      end
    end

    context 'with an invalid request timestamp' do
      let(:ultra_pod) { create :api }
      let(:private_key) { ultra_pod.private_key.secret }

      before do
        timestamp = Time.now.utc.to_i
        header 'X-Request-Timestamp', '99999999'
        header 'X-Access-Token', ultra_pod.public_key
        header 'X-Request-Hash', calculate_hmac(verb.upcase, private_key, {}, timestamp)

        public_send verb.downcase, url, {}
      end

      it 'should refute the API request' do
        expect(last_response).to be_unauthorized
      end
    end

    context 'with invalid secret' do
      let(:ultra_pod) { create :api }
      let(:private_key) { ultra_pod.private_key.secret }

      before do
        timestamp = Time.now.utc.to_i
        header 'X-Request-Timestamp', '99999999'
        header 'X-Access-Token', ultra_pod.public_key
        header 'X-Request-Hash', calculate_hmac(verb.upcase, 'weirdprivatekey', {}, timestamp)

        public_send verb.downcase, url, {}
      end

      it 'should refute the API request' do
        expect(last_response).to be_unauthorized
      end
    end

    context 'with valid auth headers' do
      let(:ultra_pod) { create :api }
      let(:private_key) { ultra_pod.private_key.secret }
      let(:params) { { what: 'ever' } }

      before do
        timestamp = Time.now.utc.to_i
        header 'X-Access-Token', ultra_pod.public_key
        header 'X-Request-Timestamp', timestamp.to_s
        header 'X-Request-Hash', calculate_hmac(verb.upcase, private_key, params, timestamp)

        public_send(verb.downcase, url, params)
      end

      it 'should accept the API request' do
        expect(last_response.status).to eq status
        expect(last_json['api']).to eq ultra_pod.name
      end
    end
  end
end

RSpec.describe Engine do
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
