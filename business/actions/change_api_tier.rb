module Actions
  class ChangeApiTier
    extend Extensions::Parameterizable

    with :api, :tier

    def call
      ActiveRecord::Base.transaction do
        api.tier_usage.deactivate!
        Models::TierUsage.create! api: api, tier: tier
      end
    end
  end
end
