module Models
  class TierUsage < ActiveRecord::Base
    belongs_to :api
    belongs_to :tier,
      class_name: "Models::Tier"

    scope :current, -> { where deactivated_at: nil }

    validates :tier, :api, presence: true

    def deactivate!
      update_attributes deactivated_at: Time.now
    end
  end
end
