require 'spec_helper'

RSpec.describe Repository do
  describe '#all' do
    context 'with no records' do
      let(:collection) { create(:collection) }

      subject { described_class.new(collection) }

      it 'should return an empty set' do
        expect(subject.all).to be_empty
      end
    end

    context 'with multiple records' do
      let(:collection) do
        create(:collection).tap do |c|
          create_list(:record, 3, collection: c)
        end
      end

      subject { described_class.new(collection) }

      it 'should return a set of Entity records' do
        subject.all.tap do |set|
          expect(set).to_not be_empty
          expect(set.all? { |i| i.is_a? Entity }).to eql true
        end
      end
    end
  end

  describe '#create' do
    context 'with a single field' do
      context 'and no validations' do
        let(:collection) do
          create(:collection).tap do |c|
            create(:field, name: 'name', collection: c)
          end
        end

        subject { described_class.new(collection) }

        before do
          subject.create(name: 'Jin Ju')
        end

        it "successfully saves the record" do
          expect(subject.count).to eql 1
          expect(subject.first.name).to eql 'Jin Ju'
        end
      end
    end

    describe 'with more than one field' do
      context 'and no validations' do
        let(:collection) do
          create(:collection).tap do |c|
            create(:field, name: 'name', collection: c)
            create(:field, name: 'weight', type: 'number', collection: c)
          end
        end

        subject { described_class.new(collection) }

        before do
          subject.create(name: 'John Kicker', weight: 75)
        end

        it do
          expect(subject.count).to eql 1
          expect(subject.first.name).to eql 'John Kicker'
          expect(subject.first.weight).to eql 75
        end
      end
    end
  end
end
