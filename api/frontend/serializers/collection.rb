module Serializers
  class Collection
    def initialize(collection)
      @collection = collection
    end

    def to_h
      {
        id: @collection.to_param,
        name: @collection.name,
        fields: @collection.fields.map(&:to_param)
      }
    end
  end
end
