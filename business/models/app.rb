module RestInMe
  class Models::App
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    extend Extensions::Sluggable
    extend Extensions::Randomizable

    store_in collection: 'apps'

    field :name,          type: ::String
    field :system_name,   type: ::String
    field :public_key,    type: ::String

    slug :name, on: :system_name
    random :public_key, length: 64

    belongs_to :client
    embeds_one :private_key
    embeds_one :app_config,
      class_name: 'RestInMe::Models::AppConfig',
      autobuild: true

    index({ system_name: 1 }, { unique: true, name: 'system_name_index' })

    validates_presence_of :name, :system_name, :client

    after_create do
      self.private_key = Models::PrivateKey.new
    end

    def has_entity?(name)
      app_config.entities.any? do |entity|
        entity['name'].to_s == name.to_s
      end
    end

    def config_for(name)
      app_config.entities.find do |entity|
        entity['name'].to_s == name.to_s
      end
    end

    def has_field?(entity_name, field_name)
      config_for(entity_name)['fields'].any? do |field_config|
        field_config['name'] == field_name.to_s
      end
    end
  end
end
