class Models::Client
  include Mongoid::Document
  include Mongoid::Timestamps
  include Extensions::Passwordable

  store_in collection: 'clients'

  field :email, type: String

  validates :email, presence: true, uniqueness: true

  has_many :apps

  class << self
    def authenticate(params)
      client = find_by(email: params[:email])
      if client.password_checks?(params[:password])
        client
      end
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end

    def find_safe(*args)
      begin
        find *args
      rescue Mongoid::Errors::DocumentNotFound
        nil
      end
    end
  end

  def signed_in?
    true
  end
end
