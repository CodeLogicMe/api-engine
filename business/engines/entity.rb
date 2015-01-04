module RestInMe
  module Entity
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

    module ClassMethods
      def field(name, type:)
        define_method(name) { @attributes.fetch(name) }
        define_method("#{name}=") { |value| @attributes[name] = value }
      end

      def create(app:, **fields)
        inst = new(app: app, **fields)

        return false unless inst.valid?
        inst.save

        inst
      end

      def persist(inst)
        collection = Array(inst.app[collection_name])
        collection << inst.attributes

        inst.app.update_attribute collection_name, collection
        inst.app.reload
      end

      def count(app)
        app.reload[collection_name].count
      end

      def collection_name
        name.demodulize.underscore.pluralize
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
    end
  end
end
