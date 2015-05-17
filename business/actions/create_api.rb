module Actions
  class CreateApi
    extend Extensions::Parameterizable

    with :api

    def call
      api = Models::Api.create! \
        client: current_client,
        name: api.name

      Models::TierUsage.create! \
        api: api,
        tier: default_tier

      api
    end

    private

    def default_tier
      Tier.find_by name: 'prototype'
    end
  end
end
