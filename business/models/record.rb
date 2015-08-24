module Models
  class Record < ActiveRecord::Base
    belongs_to :api
    belongs_to :collection

    validates :api, :collection, presence: true

    default_scope { order(created_at: :asc) }

    scope :siblings_of, -> (record) {
      if record.id
        where('records.id NOT IN (?)', record.id)
      else
        where('records.id IS NOT ?', record.id)
      end
    }

    def internal_data
      {
        id: id,
        created_at: created_at,
        updated_at: updated_at
      }
    end
  end
end
