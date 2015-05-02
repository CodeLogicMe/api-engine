require_relative '../spec_helper'

RSpec.describe Actions::AddEntity do
  context 'an entity without fields' do
    let(:app) { create :app }

    before do
      described_class.new(name: 'users').call app
    end

    it 'should add all internal fields' do
      fields = app.config_for('users')['fields']

      expect(fields.map {|field| field['name']})
        .to match_array %w(id created_at updated_at)
    end
  end
end
