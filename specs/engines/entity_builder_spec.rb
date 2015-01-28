require_relative '../spec_helper'

RSpec.describe RestInMe::EntityBuilder do
  let(:app) { create :app }

  describe 'with a single field' do
    context 'and no validations' do
      let(:config) do
        {
          name: 'croud',
          fields: [
            { name: 'id', type: 'string' },
            { name: 'Full Name', type: 'string' },
            { name: 'created_at', type: 'datetime' },
            { name: 'updated_at', type: 'datetime' },
          ]
        }
      end

      before do
        allow(app).to receive(:config_for) { config }
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

  describe 'with more than one field' do
    context 'and no validations' do
      let(:config) do
        {
          name: 'fighter',
          fields: [
            { name: 'id', type: 'string' },
            { name: 'name', type: 'string' },
            { name: 'age', type: 'integer' },
            { name: 'created_at', type: 'datetime' },
            { name: 'updated_at', type: 'datetime' },
          ]
        }
      end

      before do
        allow(app).to receive(:config_for) { config }
      end

      subject { described_class.new(app, config) }

      it do
        entity_klass = subject.call
        model = entity_klass.create(app: app, name: 'John Kicker', age: 26)

        expect(entity_klass.name).to include 'Fighter'
        expect(entity_klass.count(app)).to eq 1
        expect(model.name).to eq 'John Kicker'
        expect(model.age).to eq 26
      end
    end
  end
end
