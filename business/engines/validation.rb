module Validation
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

  module ClassMethods
    attr_reader :validations
    def validate(name, with:)
      @validations ||= []
      @validations << with.new(name)
    end
  end

  module InstanceMethods
    def valid?(entity)
      errors = check_for_errors entity

      if errors.empty?
        Succeded.new(result: entity)
      else
        Failed.new(errors: errors)
      end
    end

    private

    def check_for_errors(entity)
      self.class.validations.map { |checker|
        value = entity.public_send checker.field
        unless checker.with value
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
    attr_reader :result
    def initialize(result:)
      @result = result
    end

    def ok?
      true
    end
  end
end
