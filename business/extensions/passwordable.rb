require 'bcrypt'

module Extensions::Passwordable
  def self.included(recipient)
    recipient.class_eval do
      field :password_hash, type: String
      validates_presence_of :password_hash
    end
  end

  def password
    ::BCrypt::Password.new password_hash
  end

  def password=(new_password)
    self.password_hash = to_crypt_hash(new_password)
  end

  def password_checks?(pass)
    password == pass
  end

  private

  def to_crypt_hash(pass)
    ::BCrypt::Password.create pass
  end
end
