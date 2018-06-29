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
  before_save :alter_user_activity
  after_create :create_leave_tracker

  #
  # Plugins
  #

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  mount_uploader :avatar, AvatarUploader
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  ADMIN_USER = CONFIG['admins']

  REGISTRATION_STATUS = {
      not_registered: 0,
      not_approved: 1,
      registered: 2,
  }

  EMPLOYEE = 1
  TTF = 2
  SUPER_TTF = 3

  ROLES = [
    ['Employee', EMPLOYEE],
    ['TTF', TTF],
    ['Super TTF', SUPER_TTF]
  ]
  BLOOD_GROUPS = %w(O+ O- A+ A- B+ B- AB+ AB-)

  scope :inactive, -> {where('is_active = ?', false)}
  scope :active, -> {where('is_active = ?', true)}
  scope :published, -> { where(registration_status: 2) }
  scope :not_published, -> { where(registration_status: 1) }
  scope :not_register, -> { where(registration_status: 0) }
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

  def self.award_leave
    @robi_weekend = Weekend.where("name like ?", "%robi%").select(:id, :name).take
    User.active.each do |u|
        if u.weekend != @robi_weekend
            leaves = u.leaves.where("leave_type =? AND start_date =? ", 3, "2018-02-21")

            if leaves.count == 1
                hours = 4
            elsif leaves.count == 2
                hours = 8
            else
                hours = 0
            end

            u.leave_tracker.update_attributes!(
              :awarded_leave => u.leave_tracker.awarded_leave.present? ? u.leave_tracker.awarded_leave : 0 + hours
            )
            if hours != 0
                UserMailer.send_award_leave_notification_to_user(u, hours).deliver
                leaves.destroy_all
            end
        end
    end
  end

  def self.create_unannounced_leave
    # @robi_weekend = Weekend.where("name like ?", "%robi%").select(:id, :name).take
    # User.active.each do |u|
      # if u.approval_path.present? && u.weekend != @robi_weekend
        # Rails.logger.info "Attempting unannounced leave for #{u.name}"

        # today_entry = u.attendances.find_by(checkin_date: Date.today)

        # unless today_entry.present? || u.has_applied_for_leave || Weekend.today?(u) || HolidayScheme.today?(u)

          # Rails.logger.info "Creating unannounced leave for #{u.name}"

          # first_half_day_leave = u.leaves.where('start_date = ? AND status = ? AND half_day = ?', Time.now.to_date, Leave::ACCEPTED, Leave::FIRST_HALF).first
          # second_half_day_leave = u.leaves.where('start_date = ? AND status = ? AND half_day = ?', Time.now.to_date, Leave::ACCEPTED, Leave::SECOND_HALF).first
          # if first_half_day_leave.nil?
            # u.create_half_day_unannounced_leave(Leave::FIRST_HALF)
          # elsif second_half_day_leave.nil? && Time.now > Time.parse('today at 3:00pm')
            # u.create_half_day_unannounced_leave(Leave::SECOND_HALF)
          # end
        # end
      # end
    # end
  end

  def has_applied_for_leave
    one_day_leave = self.leaves.where('start_date = ? AND status = ? AND half_day = ?', Time.now.to_date, Leave::ACCEPTED, Leave::FULL_DAY).first
    multiple_days_leave = self.leaves.where('start_date <= ? AND end_date >= ? AND status =?', Time.now.to_date, Time.now.to_date, Leave::ACCEPTED).first

    if one_day_leave || multiple_days_leave
      return true
    end

    return false
  end

  def create_leave_tracker
    LeaveTracker::create_leave_tracker(self)
  end

  def get_co_workers
    users = User.list_of_ttfs(id) +
            User.list_of_employees(id) +
            User.where(approval_path_id: ApprovalPath.where(id: owned_paths.pluck(:approval_path_id)).pluck(:id))
    users.to_set
  end

  def approval_path_owners
    User.find(approval_path.path_chains.pluck(:user_id)).map { |owner| owner.email }
  end

  def create_half_day_unannounced_leave(half_of_the_day)
    leave = leaves.new(
        leave_type: Leave::UNANNOUNCED,
        start_date: Time.now,
        status: Leave::ACCEPTED,
        approval_path: approval_path,
        half_day: half_of_the_day,
        # pending_at: u.approval_path.try(:path_chains).try(:count))
        pending_at: 0
    )
    if leave_tracker.present? && leave.save
      leave_tracker.update_leave_tracker(leave)
      if approval_path.present?
        approval_path_owners.each do |email|
          UserMailer.send_unannounced_leave_notification_to_admin(leave, email).deliver
        end
      end
      UserMailer.send_unannounced_leave_notification_to_user(leave).deliver
      UserMailer.send_unannounced_leave_notification_to_admin(leave, CONFIG['leave_admin']).deliver
    else
      Rails.logger.info "Unable to create unannounced leave for #{name}"
    end
  end

  def alter_user_activity
    if resignation_date.present?
      self.is_active = false
      self.is_published = false
    end
    true
  end

  def all_information_provided?
     registration_status > 0
  end
end
