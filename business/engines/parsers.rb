module Parsers
  String = -> (value) { value.to_s }
  Integer = -> (value) { value.nil? ? nil : Integer(value) }
  Datetime = -> (value) { DateTime.parse(value.to_s) }
end
