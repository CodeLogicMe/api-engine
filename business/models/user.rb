module RestInMe
  class Models::User
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    include Extensions::Passwordable

    field :email, type: ::String

    embedded_in :app
    embeds_one :loose_data,
      autobuild: true,
      class_name: 'RestInMe::Models::LooseData'

    validates :email, presence: true, uniqueness: true

    after_create do
      self.loose_data.save!
    end
  end
end
