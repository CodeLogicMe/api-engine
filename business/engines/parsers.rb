module RestInMe
  module Parsers
    String = -> (value) { value.to_s }
    Integer = -> (value) { Integer(value) }
  end
end
