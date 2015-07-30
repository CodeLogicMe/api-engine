class Models::Client < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true
  validates_presence_of :password_hash

  has_many :apis

  def password=(new_password)
    self.password_hash = Context::AuthenticableClient
      .to_crypt_hash(new_password)
  end
end
