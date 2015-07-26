module Models
  class Collection < ActiveRecord::Base
    extend Extensions::Sluggable

    belongs_to :api
    has_many :fields, dependent: :destroy
    has_many :records, dependent: :destroy

    validates :api, presence: true
    validates :name, presence: true,
      uniqueness: { scope: :api }

    slug :name, on: :system_name

    default_scope { includes(:fields) }

    def has_field?(name)
      fields.where(name: name).exists?
    end
  end
end
