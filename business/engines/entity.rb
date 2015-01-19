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
        Array(app.reload[@@collection_name])
          .map { |item| build app, item }
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

      def create(app:, **fields)
        inst = new(app: app, **fields)

        inst.valid? or
          return false

        inst.attributes['created_at'] = ::Time.now.utc
        inst.attributes['updated_at'] = ::Time.now.utc
        inst.save

        inst
      end

      def persist(inst)
        collection = all(inst.app)
        collection.push inst

        inst.app.reload.update_attribute(
          @@collection_name, collection.map(&:attributes)
        )

        inst.app.reload
      end

      def delete(app:, id:)
        inst = find(app: app, id: id)

        collection = all(inst.app)
        collection.reject! do |item|
          item.id == inst.attributes.fetch(:id)
        end

        inst.app.reload.update_attribute(
          @@collection_name, collection.map(&:attributes)
        )

        inst.app.reload
      end

      def count(app)
        app.reload

        if app[@@collection_name].nil?
          0
        else
          app.reload[@@collection_name].count
        end
      end

      private

      def getter(name, parser)
        -> { parser.call @attributes.fetch(name) }
      end

      def setter(name, parser)
        -> (value) { @attributes[name] = parser.call(value) }
      end

      def build(app, params)
        inst = new(app: app, **{})
        inst.attributes = params
        inst
      end
    end

    module InstanceMethods
      def initialize(app:, **fields)
        @attributes = {}

        self.app = app
        attributes['id'] = ::BSON::ObjectId.new.to_s

        fields.each do |key, value|
          public_send "#{key}=", value
        end
      end

      attr_writer :attributes
      def attributes
        @attributes
      end

      def id
        attributes['id']
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
