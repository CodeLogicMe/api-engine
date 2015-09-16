require 'rspec'
require_relative '../api/measure'

RSpec.describe Measure do
  let(:klass) do
    Class.new do
      def foo
        'foo'
      end
      def no_foo
        'no foo'
      end
    end
  end

  before do
    allow(Skylight).to receive(:instrument).and_call_original
  end

  context 'targeting an existing method' do
    let(:receiver) do
      Measure.new klass.new, { foo: 'foo measured' }
    end

    before do
      allow(receiver).to receive(:foo).and_call_original
    end

    it 'should delegate and measure the method' do
      receiver.foo.tap do |result|
        expect(result).to eql('foo')
        expect(receiver).to have_received(:foo)
        expect(Skylight).to have_received(:instrument)
          .with({ title: 'foo measured' })
      end
    end
  end

  context 'calling a method that is not a target' do
    let(:receiver) do
      Measure.new klass.new, { foo: 'foo measured' }
    end

    before do
      allow(receiver).to receive(:no_foo).and_call_original
    end

    it 'should delegate but not measure' do
      receiver.no_foo.tap do |result|
        expect(result).to eql 'no foo'
        expect(receiver).to have_received(:no_foo)
        expect(Skylight).to_not have_received(:instrument)
      end
    end
  end

  context 'targeting a missing method' do
    let(:receiver) do
      Measure.new klass.new, { bar: 'bar measured' }
    end

    it 'should fail and not measure' do
      expect { receiver.bar }.to raise_error(NoMethodError)
      expect(Skylight).to_not have_received(:instrument)
    end
  end
end
