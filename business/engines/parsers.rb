module RestInMe
  module Parsers
    String = -> (value) { value.to_s }
    Integer = -> (value) { Integer(value) }
    Datetime = -> (value) { DateTime.parse(value.to_s) }
  end
end
