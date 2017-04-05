class HolidayScheme < ActiveRecord::Base
  has_many :exclusion_dates, as: :excluded, dependent: :destroy
  has_many :holidays, dependent: :destroy
  has_many :users

  belongs_to :leave_year

  def self.today?(user)
    today = Date.today
    counter = 0

    user.holiday_scheme.holidays.each do |holiday|
      counter += 1 if today.to_date == holiday.date.to_date
    end

    counter > 0 ? true : false
  end
end
