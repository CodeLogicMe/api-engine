require 'bcrypt'

module Models
  class Password
    attr_reader :hashed

    def initialize(value)
      @hashed = ::BCrypt::Password.create(value.to_s)
    end

    alias_method :to_str, :hashed
    alias_method :to_s, :to_str

    def ==(other)
      if other.is_a? self.class
        self.hashed == other.hashed
      else
        hashed == self.class.new(other).hashed
      end
    end

    class << self
      def load(value = nil)
        new value
      end

      def dump(obj)
        return if obj.nil?
        obj.to_str
      end
    end
  end
end
