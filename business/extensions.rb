module Extensions
  require_relative './extensions/passwordable'
  require_relative './extensions/parameterizable'

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
