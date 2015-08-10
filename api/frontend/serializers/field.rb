module Serializers
  class Field
    def initialize(field)
      @field = field
    end

    def to_h
      {
        id: @field.to_param,
        name: @field.name,
        type: @field.type,
        validations: @field.validations,
        internal: @field.internal,
        collection: @field.collection.to_param
      }
    end
  end
end
