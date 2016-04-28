module Models
  class Record < ActiveRecord::Base
    belongs_to :api
    belongs_to :collection

    validates :api, :collection, presence: true

    default_scope { order(created_at: :asc) }

    scope :siblings_of, -> (record, collection_id: nil) {
      ids = {
        collection_id: (collection_id || record.collection_id),
        id: Array(record.id || -1)
      }
      where <<~SQL, **ids
        records.collection_id = :collection_id
        AND records.id NOT IN (:id)
      SQL
    }

    def internal_data
      {
        id: id,
        created_at: created_at,
        updated_at: updated_at
      }
    end

    alias_method :to_h, :attributes
  end
end
