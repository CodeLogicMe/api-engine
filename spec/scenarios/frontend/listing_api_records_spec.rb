require 'spec_helper'

RSpec.describe Frontend, 'Listing API Records' do
  include Rack::Test::Methods

  describe 'for an existing API' do
    context 'with records' do
      let(:api) do
        create(:api).tap do |api|
          create_list(:record, 15, api: api)
        end
      end

      before do
        get "/frontend/apis/#{api.id}/records"
      end

      it 'should return a paginated list' do
        expect(last_response.status).to eql 200
      end
    end
  end
end
