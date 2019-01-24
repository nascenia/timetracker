class Holiday < ActiveRecord::Base
  belongs_to :holiday_scheme
  scope :by_year, ->(year) { where('YEAR(date) = ? ', year) }
end
