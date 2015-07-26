require 'hashie/mash'

class EntityBuilder
  def initialize(api, collection)
    @api = api
    @collection = collection
  end

  def call
    bootstrap_klass.tap &method(:mix_in_fields)
  end

  private

  def bootstrap_klass
    name = collection_name

    # I need these variables available in the next lexical scope
    api_name = @api.name.classify
    klass_name = @collection.name.classify

    Class.new do
      include Entity

      klass_name_proc = -> {
        "#{api_name}::#{klass_name}"
      }

      define_singleton_method :name, klass_name_proc
      define_singleton_method :to_s, klass_name_proc
      define_singleton_method :inspect, klass_name_proc
    end
  end

  def collection_name
    @collection.name.pluralize.underscore
  end

  def mix_in_fields(klass)
    @collection.fields.each do |f|
      FieldConfig.new(f).apply_on klass
    end
  end
end

class FieldConfig < Struct.new(:field)
  def apply_on(klass)
    field_name = proper_field_name
    parser = Parsers.const_get(field.type.capitalize)
    klass.instance_eval do
      field field_name.to_s, parser
    end
  end

  private

  def proper_field_name
    field.name.downcase.gsub /\s/, '_'
  end
end
