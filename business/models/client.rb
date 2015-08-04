require_relative '../contexts/authenticable_client'

class Models::Client < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true
  validates_presence_of :password_hash

  has_many :apis
  has_many :collections, through: :apis
  has_many :fields, through: :collections

  def password=(new_password)
    self.password_hash = Contexts::AuthenticableClient
      .to_crypt_hash(new_password)
  end
end
