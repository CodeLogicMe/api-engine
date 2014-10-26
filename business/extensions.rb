module Authk::Extensions
  module Passwordable
    require 'bcrypt'

    def self.included(recipient)
      recipient.class_eval do
        field :password_hash, type: String
        validates_presence_of :password_hash
      end
    end

    def password
      @password ||= ::BCrypt::Password.new(password_hash)
    end

    def password=(new_password)
      @password = ::BCrypt::Password.create(new_password)
      self.password_hash = @password
    end

    def password_checks?(pass)
      password == pass
    end
  end

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
          self.instance_variable_set "@#{field}", params.fetch(field)
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
