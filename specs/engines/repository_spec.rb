require_relative '../spec_helper'

RSpec.describe Repository do
  let(:app) { create :app }

  describe 'with a single field' do
    context 'and no validations' do
      let(:config) do
        {
          name: 'crouds',
          fields: [
            { name: 'id', type: 'string' },
            { name: 'Full Name', type: 'string' },
            { name: 'created_at', type: 'datetime' },
            { name: 'updated_at', type: 'datetime' },
          ]
        }
      end

      subject { described_class.new(app, 'crouds') }

      before do
        allow(app).to receive(:config_for) { config }
        subject.create(full_name: 'Jin Ju')
      end

      it do
        expect(subject.count).to eql 1
        expect(subject.first.full_name).to eql 'Jin Ju'
      end
    end
  end

  describe 'with more than one field' do
    context 'and no validations' do
      let(:config) do
        {
          name: 'fighters',
          fields: [
            { name: 'id', type: 'string' },
            { name: 'name', type: 'string' },
            { name: 'weight', type: 'integer' },
            { name: 'created_at', type: 'datetime' },
            { name: 'updated_at', type: 'datetime' },
          ]
        }
      end

      subject { described_class.new(app, 'figthers') }

      before do
        allow(app).to receive(:config_for) { config }
        subject.create(name: 'John Kicker', weight: '75')
      end

      it do
        expect(subject.count).to eql 1
        expect(subject.first.name).to eql 'John Kicker'
        expect(subject.first.weight).to eql 75
      end
    end
  end
end
