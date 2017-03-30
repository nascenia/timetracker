class HolidayScheme < ActiveRecord::Base

  has_many :holidays, dependent: :destroy
  has_many :users
  belongs_to :leave_year

  def self.today?(user)
    today = Date.today
    counter = 0
    user.holiday_scheme.holidays.each do |holiday|
      if today.to_date == holiday.date.to_date
        counter += 1
      end
    end
    if counter > 0
      return true
    else return false
    end
  end

end
