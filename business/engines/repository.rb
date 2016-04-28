require 'forwardable'
require 'kaminari/sinatra'

class Repository < Struct.new(:collection)
  extend Forwardable

  def_delegator :klass, :new, :build
  def_delegators :all, :first, :count

  def all(offset=1, amount=10)
    collection.records.page(offset).per(amount)
      .reload.map(&method(:build))
  end

  def find(id)
    build collection.records.find(id)
  end

  def valid?(obj)
    siblings = collection.records
      .siblings_of(obj).map(&:data)
    validation_klass.new.valid?(obj, context: siblings)
  end

  def update(obj, params)
    obj.attributes = params
    save obj
  end

  def save(obj)
    inst = obj.is_a?(Hash) ? build(obj) : obj
    inst.collection = collection
    valid?(inst).tap do |result|
      result.ok? and inst.persist!
    end
  end
  alias_method :create, :save

  def delete(id)
    find(id).remove!
  end

  private

  def entity
    @entity ||=
      if collection.is_a? String
        api.entities.where(name: collection)
      else
        collection
      end
  end

  def klass
    @klass ||= EntityBuilder
      .new(collection.api, collection)
      .call
  end

  def validation_klass
    @validation_klass ||=
      begin
        if collection
          ::ValidationBuilder.new(collection).call
        else
          ::ValidationBuilder::Fake
        end
      end
  end
end
