class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :attendances
  has_many :leave

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  ADMIN_USER = ['khalid@nascenia.com', 'shaer@nascenia.com', 'faruk@nascenia.com', 'fuad@nascenia.com']

  ROLES = [['Employee', 1], ['TTF', 2], ['STTF', 3]]
  EMPLOYEE = 1
  TTF = 2
  STTF = 3

  scope :inactive, -> {where("is_active =?", false)}
  scope :active, -> {where("is_active =?", true)}
  scope :ttfs, -> {where("role =?", TTF)}
  scope :sttfs, -> {where("role =?", STTF)}
  scope :employees, -> {where("role =?", EMPLOYEE)}
  def is_admin?
    self.email && ADMIN_USER.to_s.include?(self.email)
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(name: data["name"],
                         email: data["email"],
                         password: Devise.friendly_token[0,20]
      )
    end
    user
  end

  def create_attendance
    self.attendances.create(
        :user_id => self.id,
        :datetoday => Date.today,
        :in => Time.now.to_s(:time)
    )
  end

  def find_todays_entry
    todays_entry = Attendance.where(:user_id => self.id, :datetoday => Date.today, :out => nil).first
    todays_entry
  end

  def monthly_total_hour(month, year = Time.now.year)
    self.attendances.where("MONTH(datetoday) =? AND YEAR(datetoday) =?", month, year).sum(:total_hours)
  end

  def monthly_average_hour(month, saturday = 5, sunday = 6, year = Time.now.year)
    total_days_spent_in_office = self.attendances.where("MONTH(datetoday) =? AND YEAR(datetoday) =? AND WEEKDAY(datetoday) NOT IN (#{saturday}, #{sunday}) AND attendances.total_hours IS NOT NULL", month, year).count("datetoday", :distinct => true)
    monthly_total_hour = self.attendances.where("MONTH(datetoday) =? AND YEAR(datetoday) =? AND WEEKDAY(datetoday) NOT IN (#{saturday}, #{sunday})", month, year).sum(:total_hours)
    if total_days_spent_in_office > 0
      monthly_total_hour / total_days_spent_in_office
    end
  end

  def monthly_average_in_time(month, saturday = 5, sunday = 6, year = Time.now.year)
    total = self.attendances.where("MONTH(datetoday) =? AND YEAR(datetoday) =? AND WEEKDAY(datetoday) NOT IN (#{saturday}, #{sunday}) AND first_entry =? ", month, year, true).average("TIME_TO_SEC(attendances.in)")
    if total.present?
      Time.at(total).utc.strftime("%I:%M %p")
    end
  end

  def update_first_entry(today = Date.today)
    not_first_entry = self.attendances.where("datetoday =? AND first_entry =? ", today, true).count
    if not_first_entry == 0
      todays_first_entry = self.attendances.find_by_datetoday(today)
      todays_first_entry.update_attribute(:first_entry, true)
    end
  end

  def add_hours_for_missing_out(today = Date.today)
    last_office_day = self.attendances.where("datetoday !=? AND first_entry =? AND attendances.total_hours IS NULL ", today, true).last
    if last_office_day.present?
      logger.info "---Extra 2 hours Added for user #{self.email} attendance id: #{last_office_day.id}---"
      last_office_day.update_attribute(:total_hours, 2)
    end
  end

  def remember_me
    true
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << [nil, nil, "#{1.month.ago.strftime("%B")}", nil, nil, "#{2.month.ago.strftime("%B")}", nil, nil, "#{3.month.ago.strftime("%B")}", nil, nil, "#{4.month.ago.strftime("%B")}",nil, nil, "#{5.month.ago.strftime("%B")}",nil, nil, "#{6.month.ago.strftime("%B")}", nil]
      csv << ["User", "TotalHours", "Avg.Time", "Avg.InTime", "TotalHours", "Avg.Time", "Avg.InTime", "TotalHours", "Avg.Time", "Avg.InTime", "TotalHours", "Avg.Time", "Avg.InTime", "TotalHours", "Avg.Time", "Avg.InTime", "TotalHours", "Avg.Time", "Avg.InTime"]
      all.each do |user|
        csv << ["#{user.email}", "#{user.monthly_total_hour(1.month.ago.month).present? ? user.monthly_total_hour(1.month.ago.month).round : nil }", "#{user.monthly_average_hour(1.month.ago.month).present? ? user.monthly_average_hour(1.month.ago.month).round(1) : nil }", "#{user.monthly_average_in_time(1.month.ago.month).present? ? user.monthly_average_in_time(1.month.ago.month) : nil }",
                "#{user.monthly_total_hour(2.months.ago.month).present? ? user.monthly_total_hour(2.months.ago.month).round : nil }", "#{user.monthly_average_hour(2.months.ago.month).present? ? user.monthly_average_hour(2.months.ago.month).round(1) : nil }", "#{user.monthly_average_in_time(2.months.ago.month).present? ? user.monthly_average_in_time(2.months.ago.month) : nil }",
                "#{user.monthly_total_hour(3.months.ago.month).present? ? user.monthly_total_hour(3.months.ago.month).round : nil }", "#{user.monthly_average_hour(3.months.ago.month).present? ? user.monthly_average_hour(3.months.ago.month).round(1) : nil }", "#{user.monthly_average_in_time(3.months.ago.month).present? ? user.monthly_average_in_time(3.months.ago.month) : nil }",
                "#{user.monthly_total_hour(4.months.ago.month).present? ? user.monthly_total_hour(4.months.ago.month).round : nil }", "#{user.monthly_average_hour(4.months.ago.month).present? ? user.monthly_average_hour(4.months.ago.month).round(1) : nil }", "#{user.monthly_average_in_time(4.months.ago.month).present? ? user.monthly_average_in_time(4.months.ago.month) : nil }",
                "#{user.monthly_total_hour(5.months.ago.month).present? ? user.monthly_total_hour(5.months.ago.month).round : nil }", "#{user.monthly_average_hour(5.months.ago.month).present? ? user.monthly_average_hour(5.months.ago.month).round(1) : nil }", "#{user.monthly_average_in_time(5.months.ago.month).present? ? user.monthly_average_in_time(5.months.ago.month) : nil }",
                "#{user.monthly_total_hour(6.months.ago.month).present? ? user.monthly_total_hour(6.months.ago.month).round : nil }", "#{user.monthly_average_hour(6.months.ago.month).present? ? user.monthly_average_hour(6.months.ago.month).round(1) : nil }", "#{user.monthly_average_in_time(6.months.ago.month).present? ? user.monthly_average_in_time(6.months.ago.month) : nil }"]
      end
    end
  end
end