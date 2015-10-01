require_relative '../contexts/authenticable_client'
require_relative 'email'
require_relative 'password'

module Models
  class Client < ActiveRecord::Base
    serialize :email, Email
    serialize :password_hash, Password

    validates :email, presence: true, uniqueness: true
    validates_presence_of :password_hash

    has_many :apis
    has_many :collections, through: :apis
    has_many :fields, through: :collections

    def password=(value)
      self.password_hash = value.to_s
    end
  end
end
