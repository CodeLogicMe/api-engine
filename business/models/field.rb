module Models
  class Field < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    belongs_to :collection

    validates :name, presence: true,
      uniqueness: { scope: :collection }
    validates :type, presence: true

    def internal
      false
    end
  end
end
