require_relative '../spec_helper'

module RestInMe::Extensions
  RSpec.describe Parameterizable do
    klass = Class.new do
      extend Parameterizable

      with :name, :age
    end

    context 'Accessing ' do
      subject { klass.new name: 'Luke', age: 26, saber: 'green' }

      it { expect(subject.name).to eq 'Luke' }
      it { expect(subject.age).to eq 26 }
      it { expect{subject.saber}.to raise_error NoMethodError }
      it { expect(subject.instance_variable_get('@saber')).to be nil }
    end
  end
end
