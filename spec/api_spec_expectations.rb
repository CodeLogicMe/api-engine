require 'rspec/expectations'

RSpec::Matchers.define :be_unauthorized do
  match do |response|
    expect(response.status).to eql 401
    expect(parse_json(response).errors).to match_array ['Unauthorized']
  end
  failure_message do |response|
    "expected that #{response} would be Unauthorized"
  end
end

RSpec::Matchers.define :not_be_found do
  match do |response|
    expect(last_response.status).to eql 404
    expect(parse_json(response).errors).to match_array ['API could not be found']
  end
  failure_message do |response|
    "expected that API would be missing"
  end
end
