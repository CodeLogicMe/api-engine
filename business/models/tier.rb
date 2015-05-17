module Models
  class Tier
    include Mongoid::Document
    extend Extensions::Sluggable

    store_in collection: 'tiers'

    field :name, type: String
    field :system_name, type: String
    field :quota, type: Integer
    field :price, type: Float

    slug :name, on: :system_name

    has_many :apis

    validates_presence_of :name, :quota, :price, :system_name
    validates_uniqueness_of :name
  end
end
