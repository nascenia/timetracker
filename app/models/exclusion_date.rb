class ExclusionDate < ActiveRecord::Base
  belongs_to :excluded, polymorphic: true

  validates :date, presence: true
  # validates :excluded, presence: true
end
