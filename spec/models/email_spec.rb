require "rspec"
require_relative "../../business/models/email"

describe Email do
  it "comparing two different emails" do
    expect(Email.new("first@example.com"))
      .to_not eq Email.new("second@example.com")
  end

  it "comparing two equivalent emails" do
    expect(Email.new("first@example.com"))
      .to eq Email.new("FIRST@example.com")
  end

  it "should handle nil values" do
    expect(Email.new(nil).to_s).to be_empty
  end

  it "loading a raw email" do
    expect(Email.load("first@example.com")).to be_an Email
  end

  it "dumping an email" do
    email = Email.new("first@example.com")

    expect(Email.dump(email)).to eq "first@example.com"
  end

  it "trying to dumping a nil email" do
    expect(Email.dump(nil)).to be_nil
  end
end
