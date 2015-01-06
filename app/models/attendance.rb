class Attendance < ActiveRecord::Base
  belongs_to :user

  USUAL_OFFICE_TIME = "10:00"

  scope :by_month, ->(month) {where("MONTH(datetoday) =?", month)}
  scope :todays_attendance_summary, ->(date) {where("datetoday =? ", date).order(:in)}
  scope :total_employee_present, ->(date) {where("datetoday =?", date).group(:user_id).count}
  scope :raw_data_of_last_six_month, -> {where("created_at >= ? ", 6.months.ago)}

  def update_out_time
    self.update_attribute(:out, Time.now.to_s(:time))
    total_hours = ((self.out.to_time - self.in.to_time) / 1.hour).round(2)
    self.update_attribute(:total_hours, total_hours)
  end

  def summary_of_current_month(month = Time.now.month)
    self.where("MONTH(datetoday) =?", month)
  end
end
