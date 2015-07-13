module Extensions
  module Parameterizable
    def with(*fields)
      define_getters_for fields
      define_initializer_for fields
      block_child_initializers
    end

    private
    def define_getters_for(fields)
      self.class_eval do
        attr_reader *Array(fields)
      end
    end

    def define_initializer_for(fields)
      define_method 'initialize' do |params|
        fields.each do |field|
          value = params.fetch(field) { params.fetch(field.to_s) }
          self.instance_variable_set "@#{field}", value
        end
      end
    end

    def block_child_initializers
      self.class_eval do
        def self.method_added(name)
          if name == :initialize
            fail InvalidOverride, "Stop using this module if you want to have your own initializer"
          end
        end
      end
    end

    InvalidOverride = Class.new(StandardError)
  end
end
