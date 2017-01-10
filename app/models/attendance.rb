class Attendance < ActiveRecord::Base

  belongs_to :user
  has_many :children, :class_name => 'Attendance', :foreign_key => 'parent_id', :dependent => :destroy

  USUAL_OFFICE_TIME = '10:00'
  IP_WHITELIST = CONFIG['ip_whitelist']
  MONTHS = [
      ['1', 'January'],
      ['2', 'February'],
      ['3', 'March'],
      ['4', 'April'],
      ['5', 'May'],
      ['6', 'June'],
      ['7', 'July'],
      ['8', 'August'],
      ['9', 'September'],
      ['10', 'October'],
      ['11', 'November'],
      ['12', 'December']
  ]

  scope :by_month_and_year, -> (month, year) {
    where('MONTH(checkin_date) = ? AND YEAR(checkin_date) = ? AND parent_id IS NULL', month, year)
  }
  scope :daily_attendance_summary, ->(date) {
    where('checkin_date = ? AND parent_id IS NULL', date).order(:in_time)
  }
  scope :total_employee_present, ->(date) {
    where('checkin_date = ? ', date).group(:user_id).count
  }
  scope :last_six_months, -> {
    where('created_at >= ? ', 6.months.ago)
  }
  scope :monthly_attendance_summary, ->(start_date, end_date) {
    where('checkin_date >= ? AND checkin_date <= ? AND parent_id IS NULL', start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
  }

  def update_out_time
    self.update_attribute(:out_time, Time.now.to_s(:time))
    total_hours = ((self.out_time.to_time - self.in_time.to_time) / 1.hour).round(2)
    self.update_attribute(:total_hours, total_hours)
  end

  def has_multiple_checkin?
    self.children.size > 0
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ['Date', 'User', :in_time, :out_time]

      all.each do |attd|
        csv << ["#{attd.checkin_date}", "#{attd.user.present? ? attd.user.email : nil}",
                "#{attd.in_time.present? ? Time.at(attd.in_time).utc.strftime('%I:%M%p') : nil} ",
                "#{attd.out_time.present? ? Time.at(attd.out_time).utc.strftime('%I:%M%p'): nil}"]
      end
    end
  end

  def self.distinct_attendence(attendance)
    distinct_list = Array.new
    attendance.each_with_index{ |entry, index |
      last=entry
      i=index
      while( attendance[i]!=nil)
        if(entry.user.email == attendance[i].user.email)
          last =attendance[i]
        end
        i+=1
      end
      if(entry ==last )
        distinct_list.push(last)
      end
    }
    distinct_list
  end
end
