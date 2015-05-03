require 'hashie/mash'

class EntityBuilder
  def initialize(app, config)
    @app = app
    @config = Hashie::Mash.new config
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

    Class.new do
      include Entity

      klass_name_proc = -> {
        "#{app_name}::#{klass_name}"
      }

      define_singleton_method :name, klass_name_proc
      define_singleton_method :to_s, klass_name_proc
      define_singleton_method :inspect, klass_name_proc
    end
  end

  def collection_name
    @config.name.pluralize.underscore
  end

  def mix_in_fields(klass)
    @config
      .fields
      .each { |f| FieldConfig.new(f).apply_on klass }
  end
end

class FieldConfig < OpenStruct
  def apply_on(klass)
    field_name = proper_field_name
    parser = Parsers.const_get(type.capitalize)
    klass.instance_eval do
      field field_name.to_s, parser
    end
  end

  private

  def proper_field_name
    name.downcase.gsub /\s/, '_'
  end
end
