module Authk
  class Models::Client
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    include Extensions::Passwordable

    field :email, type: String

    validates :email, presence: true

    has_many :apps
  end

  class Models::App
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    extend Extensions::Sluggable
    extend Extensions::Randomizable

    field :name,          type: String
    field :system_name,   type: String
    field :public_key,    type: String

    slug :name, on: :system_name
    random :public_key, length: 64

    belongs_to :client
    embeds_many :users
    embeds_one :private_key

    index({ system_name: 1 }, { unique: true, name: 'system_name_index' })

    validates_presence_of :name, :system_name, :client

    after_create do
      self.private_key = Models::PrivateKey.new
    end
  end

  class Models::PrivateKey
    include ::Mongoid::Document
    include ::Mongoid::Timestamps::Created
    extend Extensions::Randomizable

    field :secret, type: String

    random :secret, length: 64

    embedded_in :app

    validates_presence_of :secret
  end

  class Models::User
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    include Extensions::Passwordable

    field :email, type: String

    embedded_in :app
    embeds_one :loose_data,
      autobuild: true,
      class_name: 'Authk::Models::LooseData'

    validates :email, presence: true, uniqueness: true

    after_create do
      self.loose_data.save!
    end
  end

  class Models::LooseData
    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    field :properties, type: Hash

    embedded_in :user

    def to_h
      self.properties.to_h
    end
  end
end
