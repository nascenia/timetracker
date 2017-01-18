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
  scope :last_six_months, -> {
    where('created_at >= ? ', 6.months.ago)
  }
  scope :monthly_attendance_summary, ->(start_date, end_date) {
    where('checkin_date >= ? AND checkin_date <= ? AND parent_id IS NULL', start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
  }
  scope :find_first_entry, -> (user_id, date) {
    where(:user_id => user_id, :checkin_date => date, :parent_id => nil).first
  }
  scope :find_last_entry, -> (user_id, date) {
    where(:user_id => user_id, :checkin_date => date).last
  }

  def has_multiple_checkin?
    self.children.size > 0
  end

  def self.create_attendance user_id, attendance
    self.create(
        :user_id => user_id,
        :checkin_date => Date.today,
        :in_time => Time.now.to_s(:time),
        :parent_id => attendance.nil? ? nil : attendance.parent_id
    )
  end

  def self.add_missing_checkout_hours(user)

    last_office_day = self.where('user_id = ? AND checkin_date != ? AND parent_id IS NULL AND total_hours IS NULL', user.id, Date.today).last

    if last_office_day.present?
      last_office_day.update_attribute(:total_hours, 2)
    end

  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ['Date', 'User email', 'In time', 'Out time']

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

  #
  # Method to get total hours spent in office
  #
  def self.monthly_total_hours monthly_attendance

    if monthly_attendance.nil?
      return
    end

    total_hours = 0.0

    monthly_attendance.each do |attendance|

      total_hours = total_hours + (attendance.total_hours.nil? ? 0 : attendance.total_hours)

      attendance.children.each do |child|
        total_hours = total_hours + (child.total_hours.nil? ? 0 : child.total_hours)
      end
    end

    total_hours.round(2)
  end

  #
  # Calculate monthly average attendance of a user
  #
  def self.monthly_average_hours monthly_attendances

    total_hours = self.monthly_total_hours(monthly_attendances)
    total_attendance = 1

    if monthly_attendances.size > 1
      today_attendance = monthly_attendances[monthly_attendances.size - 1]
      total_attendance = today_attendance.out_time.nil? ? monthly_attendances.size - 1 : monthly_attendances.size
    end

    average_hours = total_attendance > 0 ? total_hours / total_attendance : 0
    average_hours.round(2)
  end

  #
  # Average checkin time of a user.
  #
  def self.monthly_average_check_in_time monthly_attendance
    if monthly_attendance.size == 0
      return 0.0
    end

    total_days = monthly_attendance.size

    average_minutes = monthly_attendance.map do |attendence|
      hour, minutes = attendence.in_time.strftime('%H:%M:%S').split(':')
      total_minutes = hour.to_i * 60 + minutes.to_i
    end.inject(:+) / total_days

    average_time = '%s:%s' % average_minutes.divmod(60).map(&:to_i)
    Time.parse(average_time).strftime('%I:%M %p')
  end
end
