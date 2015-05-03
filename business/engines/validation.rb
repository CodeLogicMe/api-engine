module Validation
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

  module ClassMethods
    def validations
      @validations ||= []
    end

    def validate(name, with:)
      validations << with.new(name)
    end
  end

  module InstanceMethods
    def valid?(entity, context: nil)
      errors = check_for_errors entity, context

      if errors.empty?
        Succeded.new(result: entity)
      else
        Failed.new(errors: errors)
      end
    end
    alias_method :validate, :valid?

    private

    def check_for_errors(entity, context)
      self.class.validations.map { |checker|
        value = entity.public_send checker.field
        unless checker.with? value, context
          checker.error_message
        end
      }.compact
    end
  end

  class Failed
    attr_reader :errors
    def initialize(errors:)
      @errors = errors
    end

    def ok?
      false
    end
  end

  class Succeded
    attr_accessor :result
    def initialize(result:)
      @result = result
    end

    def ok?
      true
    end
  end
end
