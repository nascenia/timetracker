class HolidayScheme < ActiveRecord::Base

  has_many :holidays, dependent: :destroy
  has_many :users
  belongs_to :leave_year

end
