class Models::PrivateKey < ActiveRecord::Base
  extend Extensions::Randomizable

  belongs_to :api

  validates_presence_of :secret

  random :secret, length: 64
end
