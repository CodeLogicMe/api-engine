class Models::AppConfig
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :entities, type: Array, default: []

  embedded_in :app

  def entity(name:)
    entities.find do |entity|
      entity['name'].to_s == name.to_s
    end
  end
end
