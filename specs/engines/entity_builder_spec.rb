require_relative '../spec_helper'

module RestInMe
  RSpec.describe Engines::EntityBuilder do
    let(:app) { create :app }

    describe 'with a string field' do
      context 'and no validations' do
        let(:config) do
          {
            name: 'croud',
            fields: [
              type: 'string',
              field_name: 'Full Name'
            ]
          }
        end

        subject { described_class.new(app, config) }

        it do
          entity_klass = subject.call
          model = entity_klass.create(app: app, full_name: 'Jin Ju')

          expect(entity_klass.name).to include 'Croud'
          expect(entity_klass.count(app)).to eq 1
          expect(model.full_name).to eq 'Jin Ju'
        end
      end
    end
  end
end
