require "hashie/mash"
require_relative "./validation"

class ValidationBuilder
  def initialize(collection)
    @collection = collection
  end

  def call
    bootstrap_klass.tap &method(:mix_in_validations)
  end

  private

  def bootstrap_klass
    Class.new do
      include Validation
    end
  end

  def mix_in_validations(klass)
    @collection.fields
      .select { |f| Array(f.validations).any? }
      .each { |f| FieldValidation.new(f).apply_on klass }
  end

  class Fake
    def valid?(_)
      true
    end
  end
end

require "ostruct"

class FieldValidation < Struct.new(:field)
  def apply_on(klass)
    field_name = proper_field_name
    field.validations.each do |name|
      validator = Validators.const_get(name.capitalize)
      klass.instance_eval do
        validate field_name.to_s, with: validator
      end
    end
  end

  def proper_field_name
    field.name.downcase.gsub(/\s/, "_")
  end
end
