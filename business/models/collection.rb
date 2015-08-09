module Models
  class Collection < ActiveRecord::Base
    extend Extensions::Sluggable

    belongs_to :api, class_name: 'Models::Api'
    has_many :fields, dependent: :destroy
    has_many :records, dependent: :destroy

    validates :api, presence: true
    validates :name, presence: true,
      uniqueness: { scope: :api }

    slug :name, on: :system_name

    default_scope { includes(:fields).order(:name) }

    def has_field?(name)
      fields.where(name: name).exists?
    end
  end
end
