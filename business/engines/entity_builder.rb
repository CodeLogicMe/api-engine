require 'hashie/mash'

module RestInMe
  class Engines::EntityBuilder
    def initialize(app, config)
      @app = app
      @config = ::Hashie::Mash.new config
    end

    def call
      klass = bootstrap_klass

      mix_in_fields klass

      klass
    end

    private

    def bootstrap_klass
      name = collection_name

      # I need these variables available in the next lexical scope
      app_name = @app.name.classify
      klass_name = @config.name.classify

      klass = ::Class.new do
        include Entity

        store_as name

        klass_name_proc = -> {
          "<##{app_name}::#{klass_name}>"
        }

        define_singleton_method :name, klass_name_proc
        define_singleton_method :to_s, klass_name_proc
      end
    end

    def collection_name
      @config.name.pluralize.underscore
    end

    def mix_in_fields(klass)
      @config.fields
        .each { |field| FieldConfig.new(field).apply_on klass }
    end
  end

  class FieldConfig < ::OpenStruct
    def apply_on(klass)
      field_name = proper_field_name
      klass.instance_eval do
        field field_name.to_sym
      end
    end

    private

    def proper_field_name
      field_name.downcase.gsub /\s/, '_'
    end
  end
end
