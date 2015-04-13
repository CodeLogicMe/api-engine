require "hashie/mash"
require_relative "./validation"

class ValidationBuilder
  def initialize(app, config)
    @app = app
    @config = Hashie::Mash.new config
  end

  def call
    klass = bootstrap_klass

    mix_in_validations klass

    klass
  end

  private

  def bootstrap_klass
    name = collection_name

    Class.new do
      include Validation
    end
  end

  def collection_name
    @config.name.pluralize.underscore
  end

  def mix_in_validations(klass)
    @config
      .fields
      .each { |f| FieldValidation.new(f).apply_on klass }
  end

  class Fake
    def valid?(_)
      true
    end
  end
end

require "ostruct"

class FieldValidation < OpenStruct
  def apply_on(klass)
    field_name = proper_field_name
    validates.each do |name|
      validator = Validators.const_get(name.capitalize)
      klass.instance_eval do
        validate field_name.to_s, with: validator
      end
    end
  end

  def proper_field_name
    name.downcase.gsub /\s/, '_'
  end
end
