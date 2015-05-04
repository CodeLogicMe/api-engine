require "ostruct"

module Entity
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

  module ClassMethods
    def field(name, parser)
      define_method(name, &getter(name, parser))
      define_method("#{name}=", &setter(name, parser))
    end

    private

    def getter(name, parser)
      -> { parser.call @attributes[name] }
    end

    def setter(name, parser)
      -> (value) { @attributes[name] = parser.call(value) }
    end
  end

  module InstanceMethods
    def initialize(fields = {})
      @attributes = {}

      fields.each do |field, value|
        set field, value
      end
    end

    def set(field, value, force: false)
      #return if value.present? and not force

      public_send "#{field}=", value
    end

    attr_reader :attributes
    def attributes=(values)
      values.each do |key, value|
        if respond_to?("#{key}=")
          set key, value
        end
      end
    end

    def to_s
      "#<#{self.class.name} @attributes=#{@attributes}, @app_id=\"#{@app_id}\">"
    end
    alias_method :inspect, :to_s
  end
end
