class Email
  def initialize(email)
    @raw = email.to_s
  end

  def to_str
    @raw.downcase
  end
  alias_method :to_s, :to_str

  class << self
    def load(value = nil)
      new value
    end

    def dump(obj)
      return if obj.nil?
      obj.to_str
    end
  end

  def method_missing(name, *args, &block)
    super unless @raw.respond_to?(name)

    to_str.public_send(name, *args, &block)
  end

  def ==(other)
    to_str == other.to_str
  end
end
