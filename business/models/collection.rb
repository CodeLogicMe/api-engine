require 'closed_struct'

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

    default_scope { includes(:fields) }

    def has_field?(name)
      fields.where(name: name).exists?
    end

    def all_fields
      internal_fields + fields
    end

    private

    def internal_fields
      [
        InternalField.new({
          id: -1,
          name: 'id',
          type: 'text',
          validations: ['presence', 'uniqueness'],
          internal: true,
          collection: self
        }),
        InternalField.new({
          id: -2,
          name: 'created_at',
          type: 'datetime',
          validations: ['presence'],
          internal: true,
          collection: self
        }),
        InternalField.new({
          id: -3,
          name: 'updated_at',
          type: 'datetime',
          validations: ['presence'],
          internal: true,
          collection: self
        })
      ]
    end

    class InternalField < ClosedStruct
      def to_param
        id.to_s
      end
    end
  end
end
