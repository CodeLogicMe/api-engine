module Operation
  class Failed
    attr_reader :errors
    def initialize(errors:)
      @errors = errors
    end

    def ok?
      false
    end
  end

  class Succeded
    attr_reader :result
    def initialize(result:)
      @result = result
    end

    def ok?
      true
    end
  end
end
