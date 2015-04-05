class Models::PrivateKey
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  extend Extensions::Randomizable

  field :secret, type: String

  random :secret, length: 64

  embedded_in :app

  validates_presence_of :secret
end
