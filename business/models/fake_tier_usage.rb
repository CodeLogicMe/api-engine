module Models
  class FakeTierUsage
    def tier
      FakeTier.new
    end

    def deactivate!
      true
    end
  end
end
