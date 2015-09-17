require_relative "../../business/engines/parsers"

RSpec.describe Parsers do
  describe String do
    subject { Parsers::Text }

    it "with a string" do
      expect(subject.call("lukelex")).to eq "lukelex"
    end
    it "with an integer as string" do
      expect(subject.call("123")).to eq "123"
    end
    it "with an integer" do
      expect(subject.call(456)).to eq "456"
    end
  end

  describe Integer do
    subject { Parsers::Number }

    it "with an integer as string" do
      expect(subject.call("123")).to eq 123
    end
    it "with an integer" do
      expect(subject.call(123)).to eq 123
    end
  end
end
