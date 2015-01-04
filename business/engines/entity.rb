module RestInMe
  class Entity
    include ActiveModel::Validations

    @@declared_fields = Set.new
    class << self
      def field(name, type:)
        @@declared_fields << name.to_sym

        define_method(name) { @attributes.fetch(name) }
        define_method("#{name}=") { |value| @attributes[name] = value }
      end

      def create(app:, **fields)
        @@app = app
        inst = new(app: app, **fields)

        return false unless inst.valid?
        inst.save

        inst
      end

      def persist(inst)
        collection = Array(inst.app[collection_name])
        collection << inst.attributes

        inst.app.update_attribute collection_name, collection
      end

      def count
        @@app.reload[collection_name].count
      end

      def collection_name
        name.demodulize.underscore.pluralize
      end
    end

    def initialize(app:, **fields)
      @attributes = {}

      self.app = app

      @@declared_fields.each do |field_name|
        send("#{field_name}=", fields[field_name])
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
  end
end
