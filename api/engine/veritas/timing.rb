module Veritas
  class Timing
    attr_reader :started_at, :ended_at, :duration

    def initialize
      @started_at = Time.now.utc
    end

    def finish!
      @ended_at = Time.now.utc
      @duration = @ended_at - @started_at
    end

    def to_h
      {
        started_at: started_at,
        ended_at: ended_at,
        duration: duration
      }
    end
  end
end
