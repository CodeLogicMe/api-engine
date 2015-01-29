require 'ostruct'

module RestInMe
  class Repository < ::Struct.new(:app, :collection_name)
    extend Forwardable

    def_delegator :klass, :new, :build
    def_delegator :all, :first

    def all
      Array(app.reload[collection_name])
        .map { |item| build item  }
    end

    def count
      app.reload

      if app[collection_name].nil?
        0
      else
        app.reload[collection_name].count
      end
    end

    def find(id)
      item = app.reload[collection_name]
        .find { |item| item.fetch('id').to_s == id.to_s }

      klass.new item.to_h
    end

    def valid?(obj)
      true
    end

    def save(obj)
      inst = obj.is_a?(Hash) ? build(obj) : obj
      valid?(inst) && persist(inst)
    end
    alias_method :create, :save

    def delete(id)
      inst = find id

      new_collection = all.reject do |item|
        item.id == inst.attributes.fetch('id')
      end

      app.reload.update_attribute(
        collection_name, new_collection.map(&:attributes)
      )
    end

    private

    def klass
      @klass ||= begin
        config = app.reload.config_for(collection_name)
        EntityBuilder.new(app, config).call
      end
    end

    def persist(inst)
      inst.set("id", ::BSON::ObjectId.new.to_s)
      inst.set("created_at", ::Time.now.utc)
      inst.set("updated_at", ::Time.now.utc, force: true)

      new_collection = all + Array(inst)

      app.reload.update_attribute(
        collection_name, new_collection.map(&:attributes)
      )

      inst
    end
  end

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
        -> { parser.call @attributes.fetch(name) }
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
          set key, value
        end
      end

      def to_s
        "#<#{self.class.name} @attributes=#{@attributes}, @app_id=\"#{@app_id}\">"
      end
      alias_method :inspect, :to_s
    end
  end
end
