module Validators
  class Presence < Struct.new(:field)
    def with(value)
      value.present?
    end

    def error_message
      "#{field.capitalize} can't be blank"
    end
  end
end
