class User < ActiveRecord::Base
  #
  # Relationships
  #

  belongs_to :approval_path
  belongs_to :weekend
  belongs_to :holiday_scheme

  has_one :pre_registration, dependent: :destroy
  has_one :leave_tracker, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :leaves, dependent: :destroy
  has_many :owned_paths, class_name: 'PathChain'
  has_many :comments, dependent: :destroy
  has_many :timesheets, dependent: :destroy
  has_and_belongs_to_many :projects

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

  SUPER_ADMIN_USERS = CONFIG['super_admins']
  ADMIN_USERS = CONFIG['admins']

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

  def admin?
    email && ADMIN_USERS.to_s.include?(email)
  end

  def super_admin?
    email && SUPER_ADMIN_USERS.to_s.include?(email)
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

  def has_resigned?
    resignation_date.present?
  end

  def last_working_date
    has_resigned? ? resignation_date : Time.now.to_date
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    email=access_token.extra.id_info['email']
    name=access_token.info['name']
    user = User.where(:email => email).first

    unless user
      preRegistration = PreRegistration.all.where(companyEmail: email ,step_no: 2)
      is_user_found = false
      weekend_id = 0
      holiday_scheme_id = 0
      preRegistration_individual_main = nil
      preRegistration.each do |preRegistration_individual|
        if !preRegistration_individual.name.nil?
          is_user_found =true
          preRegistration_individual_main  = preRegistration_individual
          holiday_scheme_id = preRegistration_individual.holiday_scheme_id
          weekend_id = preRegistration_individual.weekend_id
          break
        end
      end
      if is_user_found
      user = User.create(name: name,
                         email: email,
                         weekend_id: weekend_id,
                         holiday_scheme_id: holiday_scheme_id,
                         password: Devise.friendly_token[0, 20])

      # pre_registration2 = PreRegistration.find.id(preRegistration_individual_main[:id])
      #   pre_registration2.step_no = 3
      # pre_registration2.update

    end
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

  def self.to_csv_timesheet(options2= {})
    options = {}
    options[:col_sep] = "\t"

    @total_hours_project_wise = {}
    @total_minutes_project_wise = {}
    @ttf_list = User.active.where(role: 2)
    @sttf_list = User.active.where(role: 3)
    @member_list = User.active.where(role: 1)
    @all_user = User.active
    projects = Project.all.where(is_active: true)
    @users = []

    options2[:end_date].tr("/", "-")
    options2[:start_date].tr("/", "-")
    date_difference = (((options2[:end_date].to_date - options2[:start_date].to_date).to_i)+ +1).to_i

    User.active.each do |user|
      begin
      ttf_name = @all_user.find(user.ttf_id).name
      rescue Exception => exc
        ttf_name = ''
      end
      begin
        sttf_name = @all_user.find(user.ttf_id).name
      rescue Exception => exc
        sttf_name = ''
      end
      tmp = { id:user.id, name: user.name , projects: [], total_sum: 0, total_sum_min: 0,ttf_name: ttf_name ,sttf_name: sttf_name}
      total_sum = 0
      total_sum_min = 0
      projects.each do |project|
        t = user.timesheets.where(project: project,date: options2[:start_date]..options2[:end_date])

        hours = t.sum(:hours)
        minutes = t.sum(:minutes)
        if @total_hours_project_wise[project.id].present?
          @total_hours_project_wise[project.id] += hours
          @total_minutes_project_wise[project.id] += minutes
        else
          @total_hours_project_wise[project.id] =0
          @total_minutes_project_wise[project.id] =0
        end

        if minutes >= 60
          hours += minutes/60
          minutes = minutes%60
        end
        total_sum+= hours
        total_sum_min+=minutes
        if(hours > 0 || minutes > 0)
          tmp[:projects] << { object: project, hours: hours, minutes: minutes }
        end
      end
      if total_sum_min >= 60
        total_sum += total_sum_min/60
        total_sum_min = total_sum_min%60
      end
      tmp[:total_sum]= total_sum
      tmp[:total_sum_min]= total_sum_min
      @users << tmp
    end
    total_holiday = 0
    holiday_list = Holiday.all.where(date: options2[:start_date].to_date..options2[:end_date].to_date)
    holiday_list.each do |holiday_list_ind|
      if !holiday_list_ind.date.nil?
        total_holiday = total_holiday+1;
      end
    end
    date_difference = date_difference - total_holiday
    CSV.generate(options) do |csv|
      csv << [ 'TTF', 'Projects', 'Name', 'Expected time to spend in office (work days - leave)*9', 'Expected productive hrs(weekly working days- Leave)*8(g)', 'Spent Hours in Office', 'Hours Logged In(i)', 'Hours not accounted for any project(g-i)/g']
      @users.each do |user|
        project_name_total = ''
        expected_time_to_spend_in_office  = date_difference*9
        expected_productive_time_to_in_office  = date_difference*8
        total_hours_spend_in_office = 0
        total_hours_logged_in = 0

        attendance_hour_count_by_date = Attendance.all.where(:user_id => user[:id],checkin_date: options2[:start_date].to_date..options2[:end_date].to_date)
        attendance_hour_count_by_date.each do |attendance_hour_count_by_date_individual|
          if !attendance_hour_count_by_date_individual.total_hours.nil?
            total_hours_spend_in_office = total_hours_spend_in_office+attendance_hour_count_by_date_individual.total_hours
          end
        end
        hour_logged_in_timesheet = Timesheet.all.where(:user_id => user[:id],date: options2[:start_date].to_date..options2[:end_date].to_date)
        hour_logged_in_timesheet.each do |hour_logged_in_timesheet_individual|
          tota_hour_logged_local = (hour_logged_in_timesheet_individual.hours*60+hour_logged_in_timesheet_individual.minutes)/60.to_f
          total_hours_logged_in = total_hours_logged_in +tota_hour_logged_local
        end
        local_date_diff = 0
        # if user[:id]== 151
        #   logger.debug "Break Points"
        # end
        leave_count_by_date = Leave.all.where(:user_id => user[:id],start_date: options2[:start_date].to_date..options2[:end_date].to_date)
        # if leave_count_by_date.size >= 1
        leave_count_by_date.each do |leave_count_by_date_individual|
          if !leave_count_by_date_individual.end_date.nil?
              if leave_count_by_date_individual.half_day == Leave::FULL_DAY
                if leave_count_by_date_individual.end_date >= options2[:end_date].to_date
                  local_date_diff = ((options2[:end_date].to_date - leave_count_by_date_individual.start_date)+1).to_i
                  logger.info user[:name]+"  END DATE : "+ leave_count_by_date_individual.end_date.to_s+" *******************************   245  "+"  START DATE : "+ leave_count_by_date_individual.start_date.to_s+" ****"+  local_date_diff.to_s
                  expected_time_to_spend_in_office  = expected_time_to_spend_in_office - (date_difference-local_date_diff)*9
                  expected_productive_time_to_in_office  = expected_productive_time_to_in_office - (date_difference-local_date_diff)*8
                else
                  local_date_diff = ((leave_count_by_date_individual.end_date - leave_count_by_date_individual.start_date)+1).to_i
                  logger.info user[:name]+"  END DATE : "+ leave_count_by_date_individual.end_date.to_s+" *******************************   250  "+"  START DATE : "+ leave_count_by_date_individual.start_date.to_s+" ****"+  local_date_diff.to_s
                  expected_time_to_spend_in_office  = (date_difference-local_date_diff)*9
                  expected_productive_time_to_in_office  = (date_difference-local_date_diff)*8
                end
              end
              if leave_count_by_date_individual.half_day == Leave::FIRST_HALF
                expected_time_to_spend_in_office  = expected_time_to_spend_in_office-4.5
                expected_productive_time_to_in_office  = expected_productive_time_to_in_office-4
              end
              if leave_count_by_date_individual.half_day == Leave::SECOND_HALF
                expected_time_to_spend_in_office  = expected_time_to_spend_in_office-4.5
                expected_productive_time_to_in_office  = expected_productive_time_to_in_office-4
              end
          # else
          #   date_diff_db = (leave_count_by_date_individual.end_date - leave_count_by_date_individual.start_date).to_i
          #   expected_time_to_spend_in_office  = (date_difference-date_diff_db)*9
          #   expected_productive_time_to_in_office  = (date_difference-date_diff_db)*8

          end
        end
        # end
          leave_count_by_date = Leave.all.where(:user_id => user[:id],end_date: options2[:start_date].to_date..options2[:end_date].to_date)
            leave_count_by_date.each do |leave_count_by_date_individual|
              if !leave_count_by_date_individual.start_date.nil?
                logger.info   user[:name]+"     ***********SIZE****************     " +leave_count_by_date.size.to_s + "     ***************************"
                if leave_count_by_date_individual.half_day == Leave::FULL_DAY
                  if leave_count_by_date_individual.start_date < options2[:start_date].to_date
                    local_date_diff = ((  leave_count_by_date_individual.end_date - options2[:start_date].to_date )+1 ).to_i
                    logger.info user[:name]+"  END DATE : "+ leave_count_by_date_individual.end_date.to_s+" *******************************   277  "+"  START DATE : "+ leave_count_by_date_individual.start_date.to_s+" ****"+  local_date_diff.to_s
                    expected_time_to_spend_in_office  = expected_time_to_spend_in_office - (date_difference-local_date_diff)*9
                    expected_productive_time_to_in_office  = expected_productive_time_to_in_office - (date_difference-local_date_diff)*8
                  # else
                  #   local_date_diff = local_date_diff+((leave_count_by_date_individual.end_date - leave_count_by_date_individual.start_date)+1).to_i
                  #   logger.info  user[:name]+"*******************************   282  "+  local_date_diff.to_s
                  #   expected_time_to_spend_in_office  = (date_difference-local_date_diff)*9
                  #   expected_productive_time_to_in_office  = (date_difference-local_date_diff)*8
                  end
                end
                if leave_count_by_date_individual.half_day == Leave::FIRST_HALF
                  expected_time_to_spend_in_office  = expected_time_to_spend_in_office-4.5
                  expected_productive_time_to_in_office  = expected_productive_time_to_in_office-4
                end
                if leave_count_by_date_individual.half_day == Leave::SECOND_HALF
                  expected_time_to_spend_in_office  = expected_time_to_spend_in_office-4.5
                  expected_productive_time_to_in_office  = expected_productive_time_to_in_office-4
                end
                # else
                #   date_diff_db = (leave_count_by_date_individual.end_date - leave_count_by_date_individual.start_date).to_i
                #   expected_time_to_spend_in_office  = (date_difference-date_diff_db)*9
                #   expected_productive_time_to_in_office  = (date_difference-date_diff_db)*8

              end
            end
        # end
        if user[:projects].size >0
          user[:projects].each do |user_project|
            if project_name_total.empty?
              project_name_total =  user_project[:object].project_name.to_s
            else
              project_name_total = project_name_total+','+ user_project[:object].project_name.to_s
            end
          end
          begin
          hours_not_accounted_for_any_project = ((expected_productive_time_to_in_office - total_hours_logged_in).to_f/expected_productive_time_to_in_office).to_f
          rescue Exception => exc
            hours_not_accounted_for_any_project = 0;
          end
          csv <<[user[:ttf_name],project_name_total,user[:name],expected_time_to_spend_in_office,expected_productive_time_to_in_office,ActionController::Base.helpers.number_with_precision(total_hours_spend_in_office, precision: 2) ,ActionController::Base.helpers.number_with_precision(total_hours_logged_in, precision: 2) ,ActionController::Base.helpers.number_to_percentage(hours_not_accounted_for_any_project*100, precision: 2)]
        end
      end
    end
  end

  def self.to_csv_monthly_report(options2= {})
    options = {}
    options[:col_sep] = "\t"

    @total_hours_project_wise = {}
    @total_minutes_project_wise = {}
    @ttf_list = User.active.where(role: 2)
    @sttf_list = User.active.where(role: 3)
    @member_list = User.active.where(role: 1)
    @all_user = User.active
    projects = Project.all.where(is_active: true)
    @users = []

    options2[:end_date].tr("/", "-")
    options2[:start_date].tr("/", "-")
    date_difference = (options2[:end_date].to_date - options2[:start_date].to_date).to_i

    User.active.each do |user|
      begin
      ttf_name = @all_user.find(user.ttf_id).name
      rescue Exception => exc
        ttf_name = ''
      end
      begin
        sttf_name = @all_user.find(user.ttf_id).name
      rescue Exception => exc
        sttf_name = ''
      end
      tmp = { id:user.id, name: user.name , projects: [], total_sum: 0, total_sum_min: 0,ttf_name: ttf_name ,sttf_name: sttf_name}
      total_sum = 0
      total_sum_min = 0
      projects.each do |project|
        t = user.timesheets.where(project: project,date: options2[:start_date]..options2[:end_date])

        hours = t.sum(:hours)
        minutes = t.sum(:minutes)
        if @total_hours_project_wise[project.id].present?
          @total_hours_project_wise[project.id] += hours
          @total_minutes_project_wise[project.id] += minutes
        else
          @total_hours_project_wise[project.id] =0
          @total_minutes_project_wise[project.id] =0
        end

        if minutes >= 60
          hours += minutes/60
          minutes = minutes%60
        end
        total_sum+= hours
        total_sum_min+=minutes
        if(hours > 0 || minutes > 0)
          tmp[:projects] << { object: project, hours: hours, minutes: minutes }
        end
      end
      if total_sum_min >= 60
        total_sum += total_sum_min/60
        total_sum_min = total_sum_min%60
      end
      tmp[:total_sum]= total_sum
      tmp[:total_sum_min]= total_sum_min
      @users << tmp
    end

    CSV.generate(options) do |csv|
      csv << ['Name','Projects','Hours' ]
      @users.each do |user|
        if user[:projects].size >0

          user[:projects].each do |user_project|
            totaltimeinhour = user_project[:hours].to_i+(user_project[:minutes].to_f/60)
            csv <<[user[:name],user_project[:object].project_name.to_s,ActionController::Base.helpers.number_with_precision(totaltimeinhour, precision: 2)]
          end
        end
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
    @robi_weekend = Weekend.where("name like ?", "%robi%").select(:id, :name).take
    User.active.each do |u|
      if u.approval_path.present? && u.weekend != @robi_weekend
        Rails.logger.info "Attempting unannounced leave for #{u.name}"

        today_entry = u.attendances.find_by(checkin_date: Date.today)

        unless today_entry.present? || u.has_applied_for_leave || Weekend.today?(u) || HolidayScheme.today?(u)

          Rails.logger.info "Creating unannounced leave for #{u.name}"

          first_half_day_leave = u.leaves.where('start_date = ? AND status = ? AND half_day = ?', Time.now.to_date, Leave::ACCEPTED, Leave::FIRST_HALF).first
          second_half_day_leave = u.leaves.where('start_date = ? AND status = ? AND half_day = ?', Time.now.to_date, Leave::ACCEPTED, Leave::SECOND_HALF).first
          if first_half_day_leave.nil?
            if Time.now > Time.parse('today at 10:30am') && Time.now < Time.parse('today at 11:30am')
              u.create_half_day_unannounced_leave(Leave::FIRST_QUARTER)
            else
              u.create_half_day_unannounced_leave(Leave::FIRST_HALF)
            end
          elsif second_half_day_leave.nil? && Time.now > Time.parse('today at 3:00pm')
            u.create_half_day_unannounced_leave(Leave::SECOND_HALF)
          end
        end
      end
    end
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

  def has_edit_permission_for?(user_to_be_edited)
    return true if super_admin?
    if admin?
      if self == user_to_be_edited
        return false
      else
        return true
      end
    end
    return false
  end

  def has_admin_privilege?
    super_admin? || admin?
  end

end
