require 'bcrypt'

module Authentik::Extensions
  module Passwordable
    include ::BCrypt

    def self.included(recipient)
      recipient.class_eval do
        field :password_hash, type: String
        validates_presence_of :password_hash
      end
    end

    def password
      @password ||= Password.new(password_hash)
    end

    def password=(new_password)
      @password = Password.create(new_password)
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
end
