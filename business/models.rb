module Authentik
  class Models::App
    include ::Mongoid::Document
    include Extensions::Passwordable
    extend Extensions::Sluggable

    field :name,          type: String
    field :system_name,   type: String

    slug :name, on: :system_name

    embeds_many :users

    index({ system_name: 1 }, { unique: true, name: "system_name_index" })

    validates_presence_of :name, :system_name
  end

  class Models::User
    include ::Mongoid::Document
    include Extensions::Passwordable

    field :email, type: String
    field :token, type: String

    embedded_in :app
  end
end
