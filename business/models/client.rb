module RestInMe
  class Models::Client
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    include Extensions::Passwordable

    store_in collection: 'clients'

    field :email, type: ::String

    validates :email, presence: true

    has_many :apps
  end
end
