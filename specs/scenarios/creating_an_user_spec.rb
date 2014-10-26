require_relative '../spec_helper'

module Authk
  module Models
    RSpec.describe User do
      context 'creating an user' do
        let(:jedi_temple) { create :app }

        subject do
          User.create \
            app: jedi_temple,
            email: 'luke@jeditemple.org',
            password: '54321'
        end

        it { expect(subject).to_not be_a_new_record }
        it { expect(subject.password_checks?(54321)).to eq true }
        it { expect(subject).to eq jedi_temple.users.first }
      end
    end
  end

  RSpec.describe API do
    include ::Rack::Test::Methods

    let(:current_app) { create :app }

    describe 'with valid info' do
      let(:params) { { email: 'anakin@sith.org', password: 'nnnooo!!!' } }

      before do
        set_auth_headers_for! current_app, params
        post '/api/users', params
      end

      it { expect(last_response.status).to eq 201 }
      it { expect(last_json["id"]).to_not be_nil }
      it { expect(last_json["email"]).to eq params[:email] }
    end

    describe 'with invalid info' do
      before do
        set_auth_headers_for! current_app, {}
        post '/api/users', {}
      end

      it { expect(last_response.status).to eq 400 }
      it { expect(last_json['error']).to eq 'email is missing, email is invalid, password is missing' }
    end

    describe 'with invalid info' do
      let(:old_user) { create :user, app: current_app }
      let(:params) { { email: old_user.email, password: 'does not matter' } }

      before do
        set_auth_headers_for! current_app, params
        post '/api/users', params
      end

      it { expect(last_response.status).to eq 400 }
      it { expect(last_json['errors']).to eq ['Email is already taken'] }
    end
  end
end
