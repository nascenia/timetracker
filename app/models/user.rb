class User < ActiveRecord::Base
  #
  # Relationships
  #

  belongs_to :approval_path
  belongs_to :weekend
  belongs_to :holiday_scheme

  has_one :leave_tracker, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :leaves, dependent: :destroy
  has_many :owned_paths, class_name: 'PathChain'
  has_many :comments, dependent: :destroy

  #
  # Callbacks
  #

  after_create :create_leave_tracker

  #
  # Plugins
  #

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  ADMIN_USER = CONFIG['admins']

  EMPLOYEE = 1
  TTF = 2
  SUPER_TTF = 3

  ROLES = [
    ['Employee', EMPLOYEE],
    ['TTF', TTF],
    ['Super TTF', SUPER_TTF]
  ]

  scope :inactive, -> {where('is_active = ?', false)}
  scope :active, -> {where('is_active = ?', true)}
  scope :ttf, -> {where('role = ?', User::TTF)}
  scope :super_ttf, -> {where('role = ?', User::SUPER_TTF)}
  scope :employees, -> {where('role = ?', User::EMPLOYEE)}
  scope :list_of_ttfs, -> (super_ttf) {where('role = ? AND sttf_id = ? ', User::TTF, super_ttf)}
  scope :list_of_employees, -> (ttf) {where('role =? AND ttf_id = ? ', User::EMPLOYEE, ttf)}
  scope :has_no_weekend, -> { where( 'weekend_id IS ?', nil) }
  scope :has_weekend, -> (weekend_id) { where( 'weekend_id IS not ? and weekend_id = ?', nil, weekend_id) }
  scope :has_no_holiday_scheme, -> { where( 'holiday_scheme_id IS ?', nil) }

  def is_admin?
    self.email && ADMIN_USER.to_s.include?(self.email)
  end

  def is_employee?
    self.role === User::EMPLOYEE
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

  def remember_me
    true
  end

  def self.to_csv(options = {})

    CSV.generate(options) do |csv|
      csv << [nil, nil, "#{1.month.ago.strftime('%B')}", nil, nil, "#{2.month.ago.strftime('%B')}", nil, nil, "#{3.month.ago.strftime('%B')}", nil, nil, "#{4.month.ago.strftime('%B')}", nil, nil, "#{5.month.ago.strftime('%B')}", nil, nil, "#{6.month.ago.strftime('%B')}", nil]
      csv << ['User email', 'Total hours', 'Average hours', 'Average in time', 'Total hours', 'Average hours', 'Average in time', 'Total hours', 'Average hours', 'Average in time', 'Total hours', 'Average hours', 'Average in time', 'Total hours', 'Average hours', 'Average in time', 'Total hours', 'Average hours', 'Average in time']

      all.each do |user|

        first_month = user.attendances.monthly_attendance_summary(1.month.ago.at_beginning_of_month, 1.month.ago.end_of_month).includes(:children)
        second_month = user.attendances.monthly_attendance_summary(2.month.ago.at_beginning_of_month, 2.month.ago.end_of_month).includes(:children)
        third_month = user.attendances.monthly_attendance_summary(3.month.ago.at_beginning_of_month, 3.month.ago.end_of_month).includes(:children)
        fourth_month = user.attendances.monthly_attendance_summary(4.month.ago.at_beginning_of_month, 4.month.ago.end_of_month).includes(:children)
        fifth_month = user.attendances.monthly_attendance_summary(5.month.ago.at_beginning_of_month, 5.month.ago.end_of_month).includes(:children)
        sixth_month = user.attendances.monthly_attendance_summary(6.month.ago.at_beginning_of_month, 6.month.ago.end_of_month).includes(:children)

        csv << [
            "#{user.email}",
            "#{Attendance.monthly_total_hours(first_month)}", "#{Attendance.monthly_average_hours(first_month)}", "#{Attendance.monthly_average_check_in_time(first_month)}",
            "#{Attendance.monthly_total_hours(second_month)}", "#{Attendance.monthly_average_hours(second_month)}", "#{Attendance.monthly_average_check_in_time(second_month)}",
            "#{Attendance.monthly_total_hours(third_month)}", "#{Attendance.monthly_average_hours(third_month)}", "#{Attendance.monthly_average_check_in_time(third_month)}",
            "#{Attendance.monthly_total_hours(fourth_month)}", "#{Attendance.monthly_average_hours(fourth_month)}", "#{Attendance.monthly_average_check_in_time(fourth_month)}",
            "#{Attendance.monthly_total_hours(fifth_month)}", "#{Attendance.monthly_average_hours(fifth_month)}", "#{Attendance.monthly_average_check_in_time(fifth_month)}",
            "#{Attendance.monthly_total_hours(sixth_month)}", "#{Attendance.monthly_average_hours(sixth_month)}", "#{Attendance.monthly_average_check_in_time(sixth_month)}"]
      end
    end
  end

  def self.create_unannounced_leave
    User.all.each do |u|
      Rails.logger.info "Attempting unannounced leave for #{u.name}"

      today_entry = u.attendances.find_by(checkin_date: Date.today)

      unless today_entry.present? || u.has_applied_for_leave || Weekend.today?(u) || HolidayScheme.today?(u)

        Rails.logger.info "Creating unannounced leave for #{u.name}"

        leave = u.leaves.new(leave_type: Leave::UNANNOUNCED,
                             start_date: Time.now,
                             status: Leave::ACCEPTED,
                             approval_path: u.approval_path,
                             pending_at: u.approval_path.try(:path_chains).try(:count))
        if leave.save
          leave.update_leave_tracker
          UserMailer.send_unannounced_leave_notification(leave).deliver
        end
      end
    end
  end

  def has_applied_for_leave
    one_day_leave = self.leaves.where('start_date = ? AND status = ?', Time.now.to_date, Leave::ACCEPTED).first
    multiple_days_leave = self.leaves.where('start_date <= ? AND end_date >= ? AND status =?', Time.now.to_date, Time.now.to_date, Leave::ACCEPTED).first

    if one_day_leave || multiple_days_leave
      return true
    end

    return false
  end

  def create_leave_tracker
    LeaveTracker::create_leave_tracker(self)
  end
end
