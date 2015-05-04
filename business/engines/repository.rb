require 'forwardable'

class Repository < Struct.new(:app, :collection_name)
  extend Forwardable

  def_delegator :klass, :new, :build
  def_delegators :all, :first, :count

  def all
    Array(app.reload[collection_name])
      .map { |record| build record  }
  end

  def find(id)
    record = Array(app.reload[collection_name])
      .find { |record| record.fetch('id').to_s == id.to_s }

    record or
      fail RecordNotFound

    klass.new record.to_h
  end

  def valid?(obj)
    siblings = all.map { |record|
      if record.id != obj.id
        record.attributes
      end
    }.compact
    validation_klass.new.valid?(obj, context: siblings)
  end

  def update(obj, params)
    obj.attributes = params
    save obj
  end

  def save(obj)
    inst = obj.is_a?(Hash) ? build(obj) : obj
    result = valid?(inst)
    result.ok? and persist(inst)
    result
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
    @klass ||=
      begin
        config = app.reload.config_for(collection_name)
        ::EntityBuilder.new(app, config).call
      end
  end

  def validation_klass
    @validation_klass ||=
      begin
        config = app.reload.config_for(collection_name)
        if config
          ::ValidationBuilder.new(app, config).call
        else
          ::ValidationBuilder::Fake
        end
      end
  end

  def persist(inst)
    inst.set('id', BSON::ObjectId.new.to_s)
    inst.set('created_at', Time.now.utc)
    inst.set('updated_at', Time.now.utc, force: true)

    new_collection = all + Array(inst)

    app.reload.update_attribute(
      collection_name, new_collection.map(&:attributes)
    )

    inst
  end

  RecordNotFound = Class.new(StandardError)
end
