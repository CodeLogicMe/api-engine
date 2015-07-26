module Models
  class SmartRequest < ActiveRecord::Base
    belongs_to :app

    validates :ip, :geolocation, :status, presence: true
    validates :started_at, :ended_at, presence: true
  end
end
