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
        internal: false,
        collection: @field.collection_id
      }
    end
  end
end
