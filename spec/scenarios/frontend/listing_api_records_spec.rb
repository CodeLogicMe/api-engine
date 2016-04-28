require "spec_helper"

RSpec.describe Frontend, "Listing API Records" do
  include Rack::Test::Methods

  describe "for an existing API" do
    context "with records" do
      let(:api) { create(:api) }
      let(:collection) do
        create(:collection, api: api).tap do |col|
          create_list(:record, 15, api: api, collection: col)
        end
      end

      before do
        login_as api.client
        get "/frontend/records", {
          api: api.id, collection: collection.system_name
        }
      end

      it "should return a paginated list" do
        expect(last_response.status).to eql 200
        expect(last_json.keys).to \
          match_array %w(records)
        expect(last_json.records.first.keys).to \
          match_array %w(id api_id collection_id data created_at updated_at)
      end
    end
  end
end
