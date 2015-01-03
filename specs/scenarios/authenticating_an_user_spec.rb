require_relative '../spec_helper'

module RestInMe
  module Actions
    RSpec.describe AuthenticateUser do
      let(:jedi_temple) { create :app }

      context 'with valid email and password' do
        let(:user) { create :user, password: '1029384756', app: jedi_temple }
        let(:params) do
          {
            app: jedi_temple,
            email: user.email,
            password: '1029384756'
          }
        end

        subject { AuthenticateUser.new(params) }

        it { expect(subject.call).to eq user }
      end

      context 'a valid email but invalid password' do
        let(:user) { create :user, app: jedi_temple }
        let(:params) do
          {
            app: jedi_temple,
            email: user.email,
            password: 'a123wrong098password'
          }
        end

        subject { AuthenticateUser.new(params) }

        it { expect{subject.call}.to raise_error AuthenticateUser::InvalidPassword }
      end

      context 'an invalid email and invalid password' do
        let(:params) do
          {
            app: jedi_temple,
            email: 'random@email.org',
            password: 'a123wrong098password'
          }
        end

        subject { AuthenticateUser.new(params) }

        it { expect{subject.call}.to raise_error ::Mongoid::Errors::DocumentNotFound }
      end
    end
  end

  RSpec.describe API do
    include ::Rack::Test::Methods

    let(:dark_temple) { create :app }
    let(:private_key) { dark_temple.private_key.secret }
    let(:user) { create :user, password: '1029384756', app: dark_temple }

    describe 'with valid credentials' do
      let(:params) { { email: user.email, password: '1029384756' } }

      before do
        set_auth_headers_for!(dark_temple, 'POST', params)
        post '/api/users/authenticate', params
      end

      it { expect(last_response.status).to eq 200 }
      it { expect(last_json['id']).to eq user.id.to_s }
      it { expect(last_json['email']).to eq user.email }
    end

    describe 'with invalid password' do
      let(:params) { { email: user.email, password: 'wrong765password' } }

      before do
        set_auth_headers_for!(dark_temple, 'POST', params)
        post '/api/users/authenticate', params
      end

      it { expect(last_response.status).to eq 404 }
    end

    describe 'with unexistant user' do
      let(:params) { { email: 'missing@email.org', password: 'wrong765password' } }

      before do
        set_auth_headers_for!(dark_temple, 'POST', params)
        post '/api/users/authenticate', params
      end

      it { expect(last_response.status).to eq 404 }
    end
  end
end
