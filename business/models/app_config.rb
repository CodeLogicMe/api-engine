class Models::AppConfig
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :entities, type: Array, default: []
  field :validations, type: Array, default: []

  embedded_in :app
end
