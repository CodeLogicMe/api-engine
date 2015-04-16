require "active_support/core_ext/object/blank"

module Validators
  Presence = Struct.new(:field) do
    def with?(value)
      value.present?
    end

    def error_message
      "#{field.to_s.capitalize} can't be blank"
    end
  end

  Size = Struct.new(:field, :size) do
    def with?(value)
      value.present? && value.size >= size
    end

    def error_message
      "#{field.to_s.capitalize} can't be smaller than #{size}"
    end
  end
end
