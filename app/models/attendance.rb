class Attendance < ActiveRecord::Base

  belongs_to :user
  has_many :children, :class_name => 'Attendance', :foreign_key => 'parent_id', :dependent => :destroy

  USUAL_OFFICE_TIME = '10:00'
  IP_WHITELIST = CONFIG['ip_whitelist']
  MONTH_LIST = [
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
    where('MONTH(checkin_date) = ? AND YEAR(checkin_date) = ? ', month, year)
  }
  scope :by_month, ->(month) {where('MONTH(checkin_date) = ? AND YEAR(checkin_date) = ? ', month, Time.now.year)}
  scope :daily_attendance_summary, ->(date) { where('checkin_date = ? AND parent_id IS NULL', date).order(:in_time) }
  scope :total_entry, ->(id){where('user_id = ?', id).count}
  scope :multi_entry, ->(date, user_id){where('checkin_date = ? AND user_id = ?',date,user_id)}
  scope :total_employee_present, ->(date) {where('checkin_date = ? ', date).group(:user_id).count}
  scope :raw_data_of_last_six_month, -> {where('created_at >= ? ', 6.months.ago)}
  scope :monthly_attendance_summary, -> { where('checkin_date >= ? AND checkin_date <= ? AND parent_id IS NULL',
                                                      Date.today.at_beginning_of_month.strftime('%Y-%m-%d'),
                                                      Date.today.strftime('%Y-%m-%d')) }

  def update_out_time
    self.update_attribute(:out_time, Time.now.to_s(:time))
    total_hours = ((self.out_time.to_time - self.in_time.to_time) / 1.hour).round(2)
    self.update_attribute(:total_hours, total_hours)
  end

  def summary_of_current_month(month = Time.now.month)
    self.where('MONTH(checkin_date) = ? ', month)
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
