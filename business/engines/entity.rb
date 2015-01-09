module RestInMe
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
        app.reload[@@collection_name]
      end

      def create(app:, **fields)
        inst = new(app: app, **fields)

        inst.valid? or
          return false

        inst.save

        inst
      end

      def persist(inst)
        collection = Array(inst.app.reload[@@collection_name])
        collection.push inst.attributes.to_hash

        inst.app.reload.update_attribute(
          @@collection_name, collection
        )

        inst.app.reload
      end

      def count(app)
        app.reload[@@collection_name].count
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

        fields.each do |key, value|
          public_send("#{key}=", value)
        end
      end

      def attributes
        attrs = Hashie::Mash.new(@attributes)
        attrs.created_at ||= Time.now.utc
        attrs.updated_at ||= Time.now.utc
        attrs
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

      def valid?
        true
      end

      def to_s
        "#<#{self.class.name} @attributes=#{@attributes}, @app_id=\"#{@app_id}\">"
      end
      alias_method :inspect, :to_s
    end
  end
end
