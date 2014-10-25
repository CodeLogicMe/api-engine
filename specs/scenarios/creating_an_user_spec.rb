require_relative '../spec_helper'

module Authentik
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

    describe 'with valid info' do
      let(:current_app) { create :app }
      let(:params) { { email: 'anakin@sith.org', password: 'nnnooo!!!' } }

      before do
        set_auth_headers_for! current_app, params
        post '/api/users', params
      end

      it { expect(last_response.status).to eq 201 }
      it { expect(last_json["id"]).to_not be_nil }
      it { expect(last_json["email"]).to eq params[:email] }
    end
  end
end
