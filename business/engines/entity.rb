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
      -> { parser.call @record.data[name.to_s] }
    end

    def setter(name, parser)
      -> (value) {
        @record.data[name.to_s] = parser.call(value)
      }
    end
  end

  module InstanceMethods
    extend Forwardable

    def initialize(record)
      @record =
        if record.is_a?(Models::Record)
          record
        else
          Models::Record.new(data: record)
        end
    end

    def set(field, value, force: false)
      #return if value.present? and not force

      public_send "#{field}=", value
    end

    def_delegator :@record, :save!, :persist!
    def_delegator :@record, :destroy, :remove!
    def_delegators :@record, :id

    def to_h
      @record.data.keys
        .map { |field| [field, public_send(field)] }
        .to_h.merge(@record.internal_data)
        .merge({ type: @record.collection.name })
    end

    attr_reader :attributes
    def attributes=(values)
      values.each do |key, value|
        if respond_to?("#{key}=")
          set key, value
        end
      end
    end

    def collection=(value)
      @record.collection = value
      if value.api
        @record.api = value.api
      end
    end

    def to_s
      "#<#{self.class.name} @data=#{@record.data} \">"
    end
    alias_method :inspect, :to_s
  end
end
