module Models
  class Tier
    include Mongoid::Document

    field :name, type: String
    field :recurrency, type: String
    field :quota, type: Integer

    has_many :apps

    validates :name, :recurrency, :quota,
      presence: true
  end
end
