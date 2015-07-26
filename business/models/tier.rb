module Models
  class Tier < ActiveRecord::Base
    extend Extensions::Sluggable

    slug :name, on: :system_name

    has_many :tier_usages
    has_many :apis, through: :tier_usages

    scope :free, -> { where(price: 0) }

    validates_presence_of :name, :quota, :price, :system_name
    validates_uniqueness_of :name

    def free?
      price == 0
    end
  end
end
