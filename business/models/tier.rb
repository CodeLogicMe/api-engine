module Models
  class Tier
    include Mongoid::Document

    store_in collection: 'tiers'

    field :name, type: String
    field :recurrency, type: String, default: 'monthly'
    field :quota, type: Integer

    has_many :apps

    validates_presence_of :name, :recurrency, :quota
  end
end
