module Extensions
  require_relative './extensions/passwordable'

  module Sluggable
    def slug(field, on: nil)
      define_method "#{field}=" do |value|
        slugged_value = self.class.to_slug value
        self.public_send "#{on}=", slugged_value
        super value
      end
    end

    def to_slug(value)
      value.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end

  module Parameterizable
    def with(*fields)
      define_getters_for fields
      define_initializer_for fields
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
  end

  module Randomizable
    require 'securerandom'

    def random(field, length: 64)
      self.instance_eval do
        after_initialize do
          unless self.public_send field
            random_str = ::SecureRandom.hex Array(length).sample/2
            self.public_send "#{field}=", random_str
          end
        end
      end
    end
  end
end
