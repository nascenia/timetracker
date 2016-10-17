class Attendance < ActiveRecord::Base

  belongs_to :user

  USUAL_OFFICE_TIME = '10:00'
  IP_WHITELIST = [
      '203.202.242.130',
      '127.0.0.1',
      '120.50.7.126'
  ]

  scope :by_month, ->(month) {where('MONTH(datetoday) = ? AND YEAR(datetoday) = ? ', month, Time.now.year)}
  scope :todays_attendance_summary, ->(date) {where('datetoday = ? ', date).order(:in_time)}
  scope :total_employee_present, ->(date) {where('datetoday = ? ', date).group(:user_id).count}
  scope :raw_data_of_last_six_month, -> {where('created_at >= ? ', 6.months.ago)}

  def update_out_time
    self.update_attribute(:out_time, Time.now.to_s(:time))
    total_hours = ((self.out_time.to_time - self.in_time.to_time) / 1.hour).round(2)
    self.update_attribute(:total_hours, total_hours)
  end

  def summary_of_current_month(month = Time.now.month)
    self.where('MONTH(datetoday) = ? ', month)
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ['Date', 'User', :in_time, :out_time]

      all.each do |attd|
        csv << ["#{attd.datetoday}", "#{attd.user.present? ? attd.user.email : nil}",
                "#{attd.in_time.present? ? Time.at(attd.in_time).utc.strftime('%I:%M%p') : nil} ",
                "#{attd.out_time.present? ? Time.at(attd.out_time).utc.strftime('%I:%M%p'): nil}"]
      end
    end
  end
end
