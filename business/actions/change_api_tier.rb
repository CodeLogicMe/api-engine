module Actions
  class ChangeApiTier
    extend Extensions::Parameterizable

    with :api, :tier

    def call
      api.tier_usage.deactivate!

      Models::TierUsage.create! api: api, tier: tier
    end
  end
end
