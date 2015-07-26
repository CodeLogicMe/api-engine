class Models::Client < ActiveRecord::Base
  include Extensions::Passwordable

  validates :email, presence: true, uniqueness: true

  has_many :apis

  def self.authenticate(params)
    client = find_by(email: params[:email])
    if client.password_checks?(params[:password])
      client
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def signed_in?
    true
  end
end
