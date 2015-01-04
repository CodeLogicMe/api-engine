require_relative '../spec_helper'

module RestInMe
  RSpec.describe Engines::EntityBuilder do
    describe 'with a string field' do
      context 'and no validations' do
        let(:config) do
          {
            name: 'crouds',
            fields: [
              type: 'string',
              field_name: 'Full Name'
            ]
          }
        end

        subject { described_class.new(config) }

        it do
          entity_klass = subject.call
          model = entity_klass.create(full_name: 'Jin Ju')
          expect(entity_klass.count).to eq 1
          expect(model.full_name).to eq 'Jin Ju'
        end
      end
    end
  end
end
