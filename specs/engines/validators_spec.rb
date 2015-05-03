require_relative "../../business/engines/validators"

RSpec.describe Validators::Presence do
  describe "#with?" do
    context "a nil value" do
      subject { described_class.new(:name) }

      it "should be invalid" do
        expect(subject.with?(nil)).to eql false
      end
    end

    context "an empty string" do
      subject { described_class.new(:name) }

      it "should be invalid" do
        expect(subject.with?("")).to eql false
      end
    end

    context "an non empty string" do
      subject { described_class.new(:name) }

      it "should be invalid" do
        expect(subject.with?("non empty")).to eql true
      end
    end

    context "an integer" do
      subject { described_class.new(:name) }

      it "should be valid" do
        expect(subject.with?(13)).to eql true
      end
    end

    context "an float" do
      subject { described_class.new(:name) }

      it "should be valid" do
        expect(subject.with?(92.37)).to eql true
      end
    end
  end
end

RSpec.describe Validators::Uniqueness do
  describe '#with?' do
    context 'an Array' do
      context 'given a nil value' do
        subject { described_class.new(:name) }

        it 'should be valid' do
          expect(subject.with?(nil, [])).to eql true
        end
      end

      context 'given an empty string' do
        subject { described_class.new(:name) }

        it 'should be valid' do
          expect(subject.with?('', [])).to eql true
        end
      end

      context 'given an existing value' do
        subject { described_class.new(:name) }

        it 'should not be valid' do
          expect(subject.with?('exists', ['exists']))
            .to eql false
        end
      end

      context 'given a non existing value' do
        subject { described_class.new(:name) }

        it 'should be valid' do
          expect(subject.with?('doesnt-exists', ['exists']))
            .to eql true
        end
      end
    end

    context 'with a hash' do
      context 'with a nil value' do
        subject { described_class.new(:email) }

        it 'should be valid' do
          expect(subject.with?(nil, {})).to eql true
        end
      end

      context 'with an empty string' do
        subject { described_class.new(:email) }

        it 'should be valid' do
          expect(subject.with?('', {})).to eql true
        end
      end

      context 'with an existing value' do
        let(:data) { [{ 'email' => 'exist@example.com'} ] }
        subject { described_class.new(:email) }

        it 'should not be valid' do
          expect(subject.with?('exist@example.com', data))
            .to eql false
        end
      end

      context 'with a non existing value' do
        let(:data) { [{ 'email' => 'exist@example.com'} ] }
        subject { described_class.new(:email) }

        it 'should be valid' do
          expect(subject.with?('doesnt-exist@example.com', data))
            .to eql true
        end
      end
    end
  end
end
RSpec.describe Validators::Size do
  describe "#with?" do
    context "a nil value" do
      subject { described_class.new(:episodes, 3) }

      it "should not be valid" do
        expect(subject.with?(nil)).to eql false
      end
    end

    context "an empty string" do
      subject { described_class.new(:episodes, 3) }

      it "should not be valid" do
        expect(subject.with?("")).to eql false
      end
    end

    context "an short string" do
      subject { described_class.new(:episodes, 7) }

      it "should not be valid" do
        expect(subject.with?("short")).to eql false
      end
    end

    context "an exact sized string" do
      subject { described_class.new(:episodes, 5) }

      it "should be valid" do
        expect(subject.with?("exact")).to eql true
      end
    end

    context "a bigger string" do
      subject { described_class.new(:episodes, 5) }

      it "should be valid" do
        expect(subject.with?("big-big-big")).to eql true
      end
    end
  end
end


