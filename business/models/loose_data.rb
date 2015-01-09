module RestInMe
  class Models::LooseData
    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    field :properties, type: ::Hash

    embedded_in :user

    def to_h
      self.properties.to_h
    end
  end
end
