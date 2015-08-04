require_relative '../engines/entity_builder'
require_relative '../extensions'

module Models
  class Api < ActiveRecord::Base
    extend Extensions::Sluggable
    extend Extensions::Randomizable

    slug :name, on: :system_name
    random :public_key, length: 64

    belongs_to :client
    has_one :private_key, dependent: :destroy
    has_many :collections, dependent: :destroy
    has_many :records
    has_many :tier_usages, dependent: :destroy
    has_many :tiers, through: :tier_usages
    has_many :requests, class_name: 'Models::SmartRequest'

    default_scope { includes(:tiers, :collections) }

    validates :name, :system_name, :client, presence: true

    before_create do
      self.tier_usages.build tier: Tier.free.first
    end
    after_create do
      self.private_key = PrivateKey.new
    end

    def has_collection?(name)
      collections.where(system_name: name).exists?
    end

    def entities
      collections.map do |collection|
        ::EntityBuilder.new(self, collection).call
      end
    end

    def collection(sys_name)
      collections.where("id = :key OR system_name = :key", key: sys_name).first!
    end

    def tier_usage
      tier_usages.current.first
    end

    def tier
      tier_usage.tier
    end
  end
end
