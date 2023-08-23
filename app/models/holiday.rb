class Holiday < ApplicationRecord
  belongs_to :holiday_scheme
  scope :by_year, -> (year) { where('YEAR(date) = ? ', year) }
end
