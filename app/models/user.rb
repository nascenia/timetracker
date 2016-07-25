class User < ActiveRecord::Base

  has_many :attendances, dependent: :destroy
  has_many :leave, dependent: :destroy
  has_one :leave_tracker, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  ADMIN_USER = [
      'khalid@nascenia.com',
      'shaer@nascenia.com',
      'faruk@nascenia.com',
      'fuad@nascenia.com'
  ]

  ROLES = [
      ['Employee', 1],
      ['TTF', 2],
      ['Super TTF', 3]
  ]
  EMPLOYEE = 1
  TTF = 2
  SUPER_TTF = 3

  scope :inactive, -> {where('is_active = ?', false)}
  scope :active, -> {where('is_active = ?', true)}
  scope :ttf, -> {where('role = ?', User::TTF)}
  scope :super_ttf, -> {where('role = ?', User::SUPER_TTF)}
  scope :employees, -> {where('role = ?', User::EMPLOYEE)}
  scope :list_of_ttfs, -> (super_ttf) {where('role = ? AND sttf_id = ? ', User::TTF, super_ttf)}
  scope :list_of_employees, -> (ttf) {where('role =? AND ttf_id = ? ', User::EMPLOYEE, ttf)}

  def is_admin?
    self.email && ADMIN_USER.to_s.include?(self.email)
  end

  def is_ttf?
    self.role === User::TTF
  end

  def is_super_ttf?
    self.role === User::SUPER_TTF
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data['email']).first

    unless user
      user = User.create(name: data['name'],
                         email: data['email'],
                         password: Devise.friendly_token[0, 20])
    end

    user
  end

  def create_attendance
    self.attendances.create(
        :user_id => self.id,
        :datetoday => Date.today,
        :in_time => Time.now.to_s(:time)
    )
  end

  def find_todays_entry
    todays_entry = Attendance.where(:user_id => self.id, :datetoday => Date.today, :out_time => nil).first
    todays_entry
  end

  def monthly_total_hour(month, year = Time.now.year)
    self.attendances.where('MONTH(datetoday) = ? AND YEAR(datetoday) = ?', month, year).sum(:total_hours)
  end

  def monthly_average_hour(month,  year = Time.now.year, saturday = 5, sunday = 6)
    total_days_spent_in_office = self.attendances.where("MONTH(datetoday) = ? AND YEAR(datetoday) = ? AND WEEKDAY(datetoday)
                                      NOT IN (#{saturday}, #{sunday}) AND attendances.total_hours IS NOT NULL", month, year)
                                     .count("datetoday", :distinct => true)
    monthly_total_hour = self.attendances.where("MONTH(datetoday) = ? AND YEAR(datetoday) = ? AND WEEKDAY(datetoday)
                                NOT IN (#{saturday}, #{sunday})", month, year)
                                .sum(:total_hours)

    if total_days_spent_in_office > 0
      monthly_total_hour / total_days_spent_in_office
    end
  end

  def monthly_average_in_time(month,  year = Time.now.year, saturday = 5, sunday = 6)
    total = self.attendances.where("MONTH(datetoday) = ? AND YEAR(datetoday) = ? AND WEEKDAY(datetoday) NOT IN (#{saturday},
                #{sunday}) AND first_entry = ? ", month, year, true)
                .average("TIME_TO_SEC(attendances.in_time)")

    if total.present?
      Time.at(total).utc.strftime("%I:%M %p")
    end
  end

  def update_first_entry(today = Date.today)
    not_first_entry = self.attendances.where("datetoday = ? AND first_entry = ? ", today, true).count
    if not_first_entry == 0
      todays_first_entry = self.attendances.find_by_datetoday(today)
      todays_first_entry.update_attribute(:first_entry, true)
    end
  end

  def add_hours_for_missing_out(today = Date.today)
    last_office_day = self.attendances.where("datetoday != ? AND first_entry = ? AND attendances.total_hours IS NULL ",
                                             today, true).last
    if last_office_day.present?
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
        csv << ["#{user.email}", "#{user.monthly_total_hour(1.month.ago.month, 1.month.ago.year).present? ? user.monthly_total_hour(1.month.ago.month, 1.month.ago.year).round : nil }", "#{user.monthly_average_hour(1.month.ago.month, 1.month.ago.year).present? ? user.monthly_average_hour(1.month.ago.month, 1.month.ago.year).round(1) : nil }", "#{user.monthly_average_in_time(1.month.ago.month, 1.month.ago.year).present? ? user.monthly_average_in_time(1.month.ago.month, 1.month.ago.year) : nil }",
                "#{user.monthly_total_hour(2.months.ago.month, 2.month.ago.year).present? ? user.monthly_total_hour(2.months.ago.month, 1.month.ago.year).round : nil }", "#{user.monthly_average_hour(2.months.ago.month, 2.month.ago.year).present? ? user.monthly_average_hour(2.months.ago.month, 2.month.ago.year).round(1) : nil }", "#{user.monthly_average_in_time(2.months.ago.month, 2.month.ago.year).present? ? user.monthly_average_in_time(2.months.ago.month, 2.month.ago.year) : nil }",
                "#{user.monthly_total_hour(3.months.ago.month, 3.month.ago.year).present? ? user.monthly_total_hour(3.months.ago.month, 3.month.ago.year).round : nil }", "#{user.monthly_average_hour(3.months.ago.month, 3.month.ago.year).present? ? user.monthly_average_hour(3.months.ago.month, 3.month.ago.year).round(1) : nil }", "#{user.monthly_average_in_time(3.months.ago.month, 3.month.ago.year).present? ? user.monthly_average_in_time(3.months.ago.month, 3.month.ago.year) : nil }",
                "#{user.monthly_total_hour(4.months.ago.month, 4.month.ago.year).present? ? user.monthly_total_hour(4.months.ago.month, 4.month.ago.year).round : nil }", "#{user.monthly_average_hour(4.months.ago.month, 4.month.ago.year).present? ? user.monthly_average_hour(4.months.ago.month, 4.month.ago.year).round(1) : nil }", "#{user.monthly_average_in_time(4.months.ago.month, 4.month.ago.year).present? ? user.monthly_average_in_time(4.months.ago.month, 4.month.ago.year) : nil }",
                "#{user.monthly_total_hour(5.months.ago.month, 5.month.ago.year).present? ? user.monthly_total_hour(5.months.ago.month, 5.month.ago.year).round : nil }", "#{user.monthly_average_hour(5.months.ago.month, 5.month.ago.year).present? ? user.monthly_average_hour(5.months.ago.month, 5.month.ago.year).round(1) : nil }", "#{user.monthly_average_in_time(5.months.ago.month, 5.month.ago.year).present? ? user.monthly_average_in_time(5.months.ago.month, 5.month.ago.year) : nil }",
                "#{user.monthly_total_hour(6.months.ago.month, 6.month.ago.year).present? ? user.monthly_total_hour(6.months.ago.month, 6.month.ago.year).round : nil }", "#{user.monthly_average_hour(6.months.ago.month, 6.month.ago.year).present? ? user.monthly_average_hour(6.months.ago.month, 6.month.ago.year).round(1) : nil }", "#{user.monthly_average_in_time(6.months.ago.month, 6.month.ago.year).present? ? user.monthly_average_in_time(6.months.ago.month, 6.month.ago.year) : nil }"]
      end
    end
  end

  def self.create_unannounced_leave
    User.all.each do |u|
      unless u.find_todays_entry.present?
        unless u.has_applied_for_leave
          leave = u.leave.create ({
              :user_id => u.id,
              :leave_type => Leave::UNANNOUNCED,
              :start_date => Time.now,
              :status => Leave::ACCEPTED
          })
          leave.update_leave_tracker
          UserMailer.send_unannounced_leave_notification(leave).deliver
        end
      end
    end
  end

  def has_applied_for_leave
    one_day_leave = self.leave.where('start_date = ? AND status = ?', Time.now.to_date, Leave::ACCEPTED).first
    multiple_days_leave = self.leave.where('start_date <= ? AND end_date >= ? AND status =?', Time.now.to_date, Time.now.to_date, Leave::ACCEPTED).first

    if one_day_leave || multiple_days_leave
      return true
    end

    return false
  end
end