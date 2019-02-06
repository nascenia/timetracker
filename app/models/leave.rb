class Leave < ActiveRecord::Base
  belongs_to :approval_path
  belongs_to :user
  belongs_to :leave_tracker

  has_many :comments

  validates :pending_at, presence: true

  CASUAL = 1
  MEDICAL = 2
  UNANNOUNCED = 3
  ROLLBACKED = 4
  AWARDED = 5
  PATERNITY = 6
  MATERNITY = 7

  LEAVE_TYPES = [
    ['Casual Leave', CASUAL],
    ['Medical Leave', MEDICAL],
    ['Awarded Leave', AWARDED],
    ['Paternity Leave', PATERNITY],
    ['Maternity Leave', MATERNITY]
  ]

  ACCEPTED = 1
  REJECTED = 2
  PENDING = 3

  HOURS_FOR_ONE_DAY = 8
  HOURS_FOR_HALF_DAY = HOURS_FOR_ONE_DAY / 2
  HOURS_FOR_QUARTER_DAY = HOURS_FOR_ONE_DAY / 4

  LEAVE_STATUSES = [
    ['Pending', PENDING],
    ['Approved', ACCEPTED],
    ['Rejected', REJECTED],
    ['Rollbacked', ROLLBACKED]
  ]

  FULL_DAY = 0
  FIRST_HALF = 1
  SECOND_HALF = 2
  FIRST_QUARTER = 3

  LEAVE_DURATIONS = [
    ['Full Day', FULL_DAY],
    ['First Half', FIRST_HALF],
    ['Second Half', SECOND_HALF]
  ]

  AWARD_DURATION= [
      ['Full Day', FULL_DAY],
      ['Half Day', FIRST_HALF]
  ]

  scope :accepted_leaves, -> { where(status: ACCEPTED) }
  scope :rejected_leaves, -> { where(status: REJECTED) }
  scope :pending_leaves, -> { where(status: PENDING) }
  scope :unannounced_leaves, -> { where('leave_type = 3') }
  scope :not_rollbacked_leaves, -> { where.not(status: ROLLBACKED) }
  scope :leaves_by_type, ->(type) { where('leave_type = ?', type)}
  scope :leaves_by_status, ->(status) { where('status = ?', status)}
  scope :leaves_by_month, ->(month) { where('MONTH(start_date) = ? OR MONTH(end_date) = ?', month, month) }
  scope :leaves_by_year, ->(year) { where('YEAR(start_date) = ? OR YEAR(end_date) = ?', year, year) }
  scope :leaves_in_between, ->(lower_date,higher_date) { where('start_date >= ? AND start_date <= ? OR end_date >= ? AND end_date <= ? OR ? >= start_date AND ? <= end_date',lower_date,higher_date,lower_date,higher_date, lower_date,higher_date) }
  scope :leaves_after, ->(date) { where('start_date > ?', date.strftime('%Y-%m-%d'))}

  # def update_leave_tracker
  #   consumed_casual_leave = self.user.leave_tracker.consumed_vacation.present? ? self.user.leave_tracker.consumed_vacation : 0
  #   consumed_medical_leave = self.user.leave_tracker.consumed_medical.present? ? self.user.leave_tracker.consumed_medical : 0
  #
  #   if self.end_date.present?
  #     total_hours = (1 + (self.end_date - self.start_date).to_i) * HOURS_FOR_ONE_DAY
  #   else
  #     total_hours = HOURS_FOR_ONE_DAY
  #   end
  #
  #   if self.half_day != 0
  #     total_hours_to_be_consumed = total_hours - HOURS_FOR_HALF_DAY
  #   else
  #     total_hours_to_be_consumed = total_hours
  #   end
  #
  #   if self.leave_type == CASUAL || self.leave_type == UNANNOUNCED
  #     consumed_casual_leave_balance = consumed_casual_leave.to_i + total_hours_to_be_consumed
  #     self.user.leave_tracker.update_attributes(:consumed_vacation => consumed_casual_leave_balance)
  #   else
  #     consumed_medical_leave_balance = consumed_medical_leave + total_hours_to_be_consumed
  #     self.user.leave_tracker.update_attributes(:consumed_medical => consumed_medical_leave_balance)
  #   end
  # end
  #
  # def revert_leave_tracker
  #   consumed_casual_leave = self.user.leave_tracker.consumed_vacation.present? ? self.user.leave_tracker.consumed_vacation : 0
  #   consumed_medical_leave = self.user.leave_tracker.consumed_medical.present? ? self.user.leave_tracker.consumed_medical : 0
  #
  #   if self.end_date.present?
  #     total_hours = (1 + (self.end_date - self.start_date).to_i) * HOURS_FOR_ONE_DAY
  #   else
  #     total_hours = HOURS_FOR_ONE_DAY
  #   end
  #
  #   if self.half_day != 0
  #     total_hours_to_be_consumed = total_hours - HOURS_FOR_HALF_DAY
  #   else
  #     total_hours_to_be_consumed = total_hours
  #   end
  #
  #   if self.leave_type == CASUAL || self.leave_type == UNANNOUNCED
  #     consumed_casual_leave_balance = consumed_casual_leave.to_i - total_hours_to_be_consumed
  #     self.user.leave_tracker.update_attributes(:consumed_vacation => consumed_casual_leave_balance)
  #   else
  #     consumed_medical_leave_balance = consumed_medical_leave - total_hours_to_be_consumed
  #     self.user.leave_tracker.update_attributes(:consumed_medical => consumed_medical_leave_balance)
  #   end
  # end

  def self.get_leaves(current_user, action)
    path_priority_list = current_user.owned_paths.pluck(:approval_path_id, :priority)

    leaves = Leave.none

    path_priority_list.each do |path_priority|
      leaves += if action == 'accepted'
                  Leave.where(approval_path_id: path_priority[0]).where('pending_at < ?', path_priority[1])
                elsif action == 'rejected'
                  Leave.where(approval_path_id: path_priority[0], status: Leave::REJECTED, pending_at: path_priority[1])
                else
                  Leave.where(approval_path_id: path_priority[0], pending_at: path_priority[1], status: Leave::PENDING)
                end
    end
    leaves
  end

  def is_awarded?
    leave_type == AWARDED || leave_type == MATERNITY || leave_type == PATERNITY
  end

  def is_pending?
    status == PENDING
  end

  def is_accepted?
    status == ACCEPTED
  end

  def is_rejected?
    status == REJECTED
  end

  def self.get_users_on_leave_today
    today = Date.today
    @all_approved_leaves = Leave.where( 'status = 1 and ? > start_date and ? < end_date',
                                        today+1.day, today-1.day )
  end

  def get_leave_type_in_string
    leave_type == 1 ? 'Casual' : 'Medical'
    if leave_type == CASUAL
      'Casual'
    elsif leave_type == MEDICAL
      'Medical'
    elsif leave_type == AWARDED
      'Awarded'
    end
  end


  def self.get_half_day_leaves_count user_id
    first_half_leaves = Leave.where('user_id = ? and half_day = 1 and created_at >= ? and created_at <= ?', user_id, Date.today.at_beginning_of_month.strftime('%Y-%m-%d'), Date.today.strftime('%Y-%m-%d')).to_a
    second_half_leaves = Leave.where('user_id = ? and half_day = 2 and created_at >= ? and created_at <= ?', user_id, Date.today.at_beginning_of_month.strftime('%Y-%m-%d'), Date.today.strftime('%Y-%m-%d')).to_a
    half_day_leaves_count = 0;
    first_half_leaves.each do  |f|
      flag = 0;
      second_half_leaves.each do |s|
        if f.created_at.strftime('%Y-%m-%d') == s.created_at.strftime('%Y-%m-%d')
          flag = 1;
          break;
        end
      end
      half_day_leaves_count +=1 if flag == 0
    end
    half_day_leaves_count

  end

  def number_of_days
    if user.holiday_scheme && user.weekend
      dates = (start_date..end_date).map(&:to_date) - user.holiday_scheme.holidays.map { |holiday| holiday.date }

      (dates.map(&:to_date).map { |day| day.strftime('%A') } - user.weekend.off_days.map(&:capitalize).map(&:to_s)).count
    else
      0
    end

  end

  def total_leave_hour_of(month)
    return hour if leave_type == AWARDED

    if end_date.present? && half_day == 0
      dates = (start_date..end_date).map(&:to_date) - user.holiday_scheme.holidays.map { |holiday| holiday.date }
      weekend = user.weekend.off_days.map(&:capitalize).map(&:to_s)
      dates.delete_if { |date| weekend.include?(date.strftime('%A')) || date.strftime('%m') != month }
      dates.count * HOURS_FOR_ONE_DAY
    else
      if half_day == 0
        Leave::HOURS_FOR_ONE_DAY
      else
        Leave::HOURS_FOR_HALF_DAY
      end
    end
  end

  def total_leave_hour
    return hour if leave_type == AWARDED


    if leave_type == UNANNOUNCED
      if half_day == FIRST_QUARTER
        total_hours_to_be_consumed = HOURS_FOR_QUARTER_DAY
      elsif half_day == FIRST_HALF
        if quarter_day_leave_present?
          total_hours_to_be_consumed = HOURS_FOR_QUARTER_DAY
        else
          total_hours_to_be_consumed = HOURS_FOR_HALF_DAY
        end
      elsif half_day == SECOND_HALF
        total_hours_to_be_consumed = HOURS_FOR_HALF_DAY
      end
    else
      total_hours = if end_date.present?
                      number_of_days * HOURS_FOR_ONE_DAY
                    else
                      HOURS_FOR_ONE_DAY
                    end

      total_hours_to_be_consumed = if half_day != 0
                                     total_hours - HOURS_FOR_HALF_DAY
                                   else
                                     total_hours
                                   end
    end
    total_hours_to_be_consumed
  end
  def valid_date?
    start_date.present? && start_date <= Time.now if leave_type == AWARDED
    if leave_type == PATERNITY || leave_type == MATERNITY
      start_date.present? && end_date.present? && start_date <= end_date
    end
  end

  def quarter_day_leave_present?
    Leave.where(:user=> user, :start_date=> start_date,:half_day=> FIRST_QUARTER,:leave_type=> UNANNOUNCED).present?
  end
end
