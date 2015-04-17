require 'forwardable'

class Repository < Struct.new(:app, :collection_name)
  extend Forwardable

  def_delegator :klass, :new, :build
  def_delegators :all, :first, :count

  def all
    Array(app.reload[collection_name])
      .map { |item| build item  }
  end

  def find(id)
    item = app.reload[collection_name]
      .find { |item| item.fetch('id').to_s == id.to_s }

    klass.new item.to_h
  end

  def valid?(obj)
    validation_klass.new.valid?(obj)
  end

  def save(obj)
    inst = obj.is_a?(Hash) ? build(obj) : obj
    result = valid?(inst)
    persist(inst)
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
    inst.set("id", BSON::ObjectId.new.to_s)
    inst.set("created_at", Time.now.utc)
    inst.set("updated_at", Time.now.utc, force: true)

    new_collection = all + Array(inst)

    app.reload.update_attribute(
      collection_name, new_collection.map(&:attributes)
    )

    inst
  end
end
