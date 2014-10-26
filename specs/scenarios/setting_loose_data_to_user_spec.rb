require_relative '../spec_helper'

module Authk
  module Actions
    RSpec.describe SetLooseData do
      let(:jedi_temple) { create :app }

      context 'filling the data' do
        let(:user) { create :user, app: jedi_temple }
        let(:params) do
          {
            app: jedi_temple,
            user_id: user.id.to_s,
            data: {
              previous_saber: 'yellow',
              current_saber: 'blue',
              saber_type: 'dual'
            }
          }
        end

        subject { SetLooseData.new(params) }

        it { expect(subject.call.to_h).to eq params[:data] }
      end

      context 'emptying the data' do
        let(:user) { create :user_with_loose_data, app: jedi_temple }
        let(:params) do
          {
            app: jedi_temple,
            user_id: user.id.to_s,
            data: {}
          }
        end

        subject { SetLooseData.new(params) }

        it { expect(subject.call.to_h).to eq Hash.new }
      end
    end
  end

  RSpec.describe API do
    include ::Rack::Test::Methods

    let(:dark_temple) { create :app }
    let(:user) { create :user, app: dark_temple }

    describe 'Updating data for an existing user' do
      let(:params) { { data: { 'new_saber' => 'red' } } }

      before do
        set_auth_headers_for!(dark_temple, 'PUT', params)
        put "/api/users/#{user.id}/data", params
      end

      it { expect(last_response.status).to eq 201 }
      it { expect(last_json['data']).to eq params[:data] }
    end

    describe 'Updating data for an unexisting user' do
      let(:params) { { data: { 'new_saber' => 'red' } } }

      before do
        set_auth_headers_for!(dark_temple, 'PUT', params)
        put "/api/users/019283u092183/data", params
      end

      it { expect(last_response.status).to eq 404 }
    end
  end
end
