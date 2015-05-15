require_relative '../engines/entity_builder'
require_relative '../extensions'

module Models
  class App
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Extensions::Sluggable
    extend Extensions::Randomizable

    store_in collection: "apps"

    field :name,          type: String
    field :system_name,   type: String
    field :public_key,    type: String

    slug :name, on: :system_name
    random :public_key, length: 64

    belongs_to :client
    embeds_one :private_key
    embeds_one :app_config,
      class_name: 'Models::AppConfig',
      autobuild: true
    belongs_to :tier
    embeds_many :requests,
      class_name: 'Models::SmartRequest'

    index({ system_name: 1 }, { unique: true, name: "system_name_index" })

    validates_presence_of :name, :system_name, :client

    after_create do
      self.private_key = PrivateKey.new
    end

    def to_param
      system_name
    end

    def has_entity?(name)
      app_config.entities.any? do |entity|
        entity['name'].to_s == name.to_s
      end
    end

    def config_for(name)
      Hashie::Mash.new app_config.entities.find { |entity|
        entity['name'].to_s == name.to_s
      }.to_h
    end

    def has_field?(entity_name, field_name)
      Repositories::Fields
        .new(app: self, entity: config_for(entity_name))
        .exists?(field_name)
    end

    def entities
      app_config.entities.map do |entity|
        Engines::EntityBuilder.new(self, entity).call
      end
    end
  end
end
