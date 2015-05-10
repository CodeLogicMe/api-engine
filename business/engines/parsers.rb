require 'bigdecimal'

module Parsers
  Text = -> (value) { value.to_s }
  Number = -> (value) { value.nil? ? nil : BigDecimal.new(value) }
  Datetime = -> (value) { ::DateTime.parse(value.to_s) }
end
