module RestInMe
  class Repository < ::Struct.new(:app, :collection_name)
    require 'ostruct'

    def klass
      @klass ||= begin
        config = app.config_for(collection_name)
        EntityBuilder.new(app, config).call
      end
    end

    def build(obj)
      inst = klass.new(app: app, **{})
      inst.attributes = obj
      inst
    end

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

    def valid?(obj)
      true
    end

    def create(obj)
      valid?(obj) && persist(obj)
    end

    def save(obj)
      valid?(obj) && persist(obj)
    end

    def persist(obj)
      obj['id'] ||= ::BSON::ObjectId.new.to_s

      inst = obj.is_a?(Hash) ? build(obj) : obj

      collection = all
      collection.push inst

      app.reload.update_attribute(
        collection_name, collection.map(&:attributes)
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

      def store_as(name)
        @@collection_name = name
      end

      def all(app)
        Repository.new(app, @@collection_name).all
      end

      def find(app:, id:)
        item = app.reload[@@collection_name].find { |item|
          item.fetch('id').to_s == id.to_s
        }.inject({}) do |memo, (k,v)|
          memo[k.to_sym] = v; memo
        end

        inst = new app: app
        inst.attributes = item.to_hash
        inst
      end

      def create(app:, **obj)
        obj

        repo = Repository.new(app, @@collection_name)
        repo.valid?(obj) or
          return false

        obj['created_at'] = ::Time.now.utc
        obj['updated_at'] = ::Time.now.utc

        repo.create(obj)
      end

      def persist(obj)
        Repository
          .new(app, @@collection_name)
          .persist(obj)
      end

      def delete(app:, id:)
        inst = find(app: app, id: id)

        collection = all(inst.app)
        collection.reject! do |item|
          item.id == inst.attributes.fetch('id')
        end

        inst.app.reload.update_attribute(
          @@collection_name, collection.map(&:attributes)
        )

        inst.app.reload
      end

      def count(app)
        Repository.new(app, @@collection_name).count
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
      def initialize(app:, **fields)
        @attributes = {}

        self.app = app

        fields.each do |field, value|
          set field, value
        end
      end

      def set(field, value)
        public_send "#{field}=", value
      end

      attr_reader :attributes
      def attributes=(values)
        values.each do |key, value|
          set key, value
        end
      end

      def id
        @attributes['id']
      end

      def save
        valid? and
          self.class.persist(self)
      end

      def app=(value)
        @app_id = value.to_param
      end

      def app
        @app ||= Models::App.find(@app_id)
      end

      def to_s
        "#<#{self.class.name} @attributes=#{@attributes}, @app_id=\"#{@app_id}\">"
      end
      alias_method :inspect, :to_s
    end
  end
end
