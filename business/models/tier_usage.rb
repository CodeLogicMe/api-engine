module Models
  class TierUsage
    include Mongoid::Document
    include Mongoid::Timestamps::Created

    store_in collection: 'tier_usages'

    field :deactivated_at, type: Time

    embedded_in :api
    belongs_to :tier

    scope :current, -> { where deactivated_at: nil }

    validates_presence_of :tier

    def deactivate!
      update_attributes deactivated_at: Time.now
    end
  end
end
