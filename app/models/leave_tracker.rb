class LeaveTracker < ApplicationRecord
  belongs_to :user
  has_many :leave

  attr_accessor :award_leave

  # TODO: move this to configuration settings
  YEARLY_CASUAL_LEAVE = 80
  YEARLY_MEDICAL_LEAVE = 48

  CASUAL_LEAVE_IN_DAYS = 10
  MEDICAL_LEAVE_IN_DAYS = 6

  def self.populate_with_default_yearly_leave
    User.active.each do |user|
      self.create ({
        :user_id => user.id,
        :yearly_casual_leave => YEARLY_CASUAL_LEAVE,
        :yearly_medical_leave =>  YEARLY_MEDICAL_LEAVE
      })
    end
  end

  def self.create_leave_tracker(user)
    self.create ({
      :user_id => user.id,
      :yearly_casual_leave => YEARLY_CASUAL_LEAVE,
      :yearly_medical_leave =>  YEARLY_MEDICAL_LEAVE,
      :consumed_vacation => 0,
      :consumed_medical => 0,
      :accrued_vacation_this_year => 0,
      :accrued_medical_this_year => 0,
      :carried_forward_vacation => 0,
      :carried_forward_medical => 0,
      :commenced_date => Time.now
    })
  end

  def self.populate_with_commenced_date
    User.active.each do |user|
      if user.leave_tracker.present?
        user.leave_tracker.update_attribute(:commenced_date, Time.now.at_beginning_of_year)
      end
    end
  end

  def self.populate_with_carried_forward_leave
    User.active.each do |user|
      if user.leave_tracker.present?

        avb = user.leave_tracker.accrued_vacation_balance
        amb = user.leave_tracker.accrued_medical_balance
        carried_forward_vacation = [80, avb + [amb, 0].min].min
        carried_forward_medical = 0

        user.leave_tracker.update_attribute(:carried_forward_vacation, carried_forward_vacation)
        user.leave_tracker.update_attribute(:carried_forward_medical, carried_forward_medical)
      end
    end
  end

  def self.populate_with_consumed_leave
    User.active.each do |user|
      if user.leave_tracker.present?
        user.leave_tracker.update_attributes(:consumed_vacation => 0, :consumed_medical => 0)
      end
    end
  end

  def update_leave_tracker(leave)
    consumed_casual_leave = consumed_vacation.present? ? consumed_vacation : 0
    consumed_medical_leave = consumed_medical.present? ? consumed_medical : 0

    total_hours_to_be_consumed = leave.total_leave_hour

    if leave.leave_type == Leave::CASUAL || leave.leave_type == Leave::UNANNOUNCED
      consumed_casual_leave_balance = consumed_casual_leave.to_i + total_hours_to_be_consumed
      update_attributes(:consumed_vacation => consumed_casual_leave_balance)
    elsif leave.leave_type == Leave::MEDICAL
      consumed_medical_leave_balance = consumed_medical_leave + total_hours_to_be_consumed
      update_attributes(:consumed_medical => consumed_medical_leave_balance)
    elsif leave.leave_type == Leave::AWARDED
      awarded_leave_balance = awarded_leave + total_hours_to_be_consumed
      update_attributes(:awarded_leave => awarded_leave_balance)
    end
  end

  def revert_leave_tracker(leave)
    consumed_casual_leave = consumed_vacation.present? ? consumed_vacation : 0
    consumed_medical_leave = consumed_medical.present? ? consumed_medical : 0
    total_hours_to_be_consumed = leave.total_leave_hour

    if leave.leave_type == Leave::CASUAL || leave.leave_type == Leave::UNANNOUNCED
      consumed_casual_leave_balance = consumed_casual_leave.to_i - total_hours_to_be_consumed
      update_attributes(:consumed_vacation => consumed_casual_leave_balance)
    elsif leave.leave_type == Leave::MEDICAL
      consumed_medical_leave_balance = consumed_medical_leave - total_hours_to_be_consumed
      update_attributes(:consumed_medical => consumed_medical_leave_balance)
    elsif leave.leave_type == Leave::AWARDED
      awarded_leave_balance = awarded_leave - total_hours_to_be_consumed
      update_attributes(:awarded_leave => awarded_leave_balance)
    end
  end

  def update_rollback_leave_tracker
    if user.has_resigned?
      user.leaves.each do |leave|
        if leave.start_date > user.resignation_date
          if leave.status == Leave::ACCEPTED
            revert_leave_tracker(leave)
            leave.status=Leave::ROLLBACKED
            leave.save
          end
        else
          if leave.status == Leave::ROLLBACKED
            update_leave_tracker(leave)
            leave.status=Leave::ACCEPTED
            leave.save
          end
        end
      end
    else
      user.leaves.each do |leave|
          if leave.status == Leave::ROLLBACKED
            update_leave_tracker(leave)
            leave.status=Leave::ACCEPTED
            leave.save
          end
      end
    end
  end

  def update_leave_tracker_daily
    if self.commenced_date.present?

      update_rollback_leave_tracker

      accrued_vacation_this_year = ((((self.user.last_working_date - self.commenced_date.to_date).to_i) * CASUAL_LEAVE_IN_DAYS/365.0) * 8).to_i
      accrued_medical_this_year = ((((self.user.last_working_date - self.commenced_date.to_date).to_i) * MEDICAL_LEAVE_IN_DAYS/365.0) * 8).to_i
      if self.carried_forward_vacation.nil?
        accrued_total_vacation = accrued_vacation_this_year
      else
        accrued_total_vacation = self.carried_forward_vacation + accrued_vacation_this_year
      end

      if self.carried_forward_medical.nil?
        accrued_total_medical = accrued_medical_this_year
      else
        accrued_total_medical = self.carried_forward_medical +  accrued_medical_this_year
      end

      if self.awarded_leave.nil?
        accrual_vacation_balance = accrued_total_vacation - self.consumed_vacation
      else
        accrual_vacation_balance = accrued_total_vacation + self.awarded_leave - self.consumed_vacation
      end
      accrual_medical_balance = accrued_total_medical - self.consumed_medical

      self.update(
        :accrued_vacation_total => accrued_total_vacation,
        :accrued_medical_total => accrued_total_medical,
        :accrued_vacation_balance => accrual_vacation_balance,
        :accrued_medical_balance => accrual_medical_balance,
        :accrued_vacation_this_year => accrued_vacation_this_year,
        :accrued_medical_this_year => accrued_medical_this_year
      )
    end
  end

  def self.update_leave_tracker_yearly
    User.active.each do |user|
      if user.leave_tracker
        user.leave_tracker.update_leave_tracker_daily
      else
        LeaveTracker::create_leave_tracker(user)
      end
    end
  end

  def self.initialize_every_leave_with_new_year
    User.active.each do |user|
      if user.leave_tracker.present?
        user.leave_tracker.update_attributes(
          :yearly_casual_leave => YEARLY_CASUAL_LEAVE,
          :yearly_medical_leave => YEARLY_MEDICAL_LEAVE,
          :accrued_vacation_this_year => 0,
          :accrued_medical_this_year => 0,
          :awarded_leave => 0,
        )
      end
    end
    self.populate_with_carried_forward_leave
    self.populate_with_consumed_leave
    self.populate_with_commenced_date
  end

  def update_leave_tracker_when_awarded(award, note)
    if self.commenced_date.present?
      accrued_vacation_this_year = ((((self.user.last_working_date - self.commenced_date.to_date).to_i) * CASUAL_LEAVE_IN_DAYS/365.0) * 8).to_i
      accrued_medical_this_year = ((((self.user.last_working_date - self.commenced_date.to_date).to_i) * MEDICAL_LEAVE_IN_DAYS/365.0) * 8).to_i
      accrued_total_vacation = self.carried_forward_vacation + accrued_vacation_this_year
      accrued_total_medical = self.carried_forward_medical +  accrued_medical_this_year
      awarded_leave = self.awarded_leave + award.to_i
      accrual_vacation_balance = accrued_total_vacation + awarded_leave - self.consumed_vacation
      accrual_medical_balance = accrued_total_medical - self.consumed_medical

      self.update_attributes!(
          :accrued_vacation_total => accrued_total_vacation,
          :accrued_medical_total => accrued_total_medical,
          :accrued_vacation_balance => accrual_vacation_balance,
          :accrued_medical_balance => accrual_medical_balance,
          :accrued_vacation_this_year => accrued_vacation_this_year,
          :accrued_medical_this_year => accrued_medical_this_year,
          :awarded_leave => awarded_leave,
          :note => note
      )
    end
  end

  def casual_or_medical_leave_present_after_resignation
    if user.resignation_date.present?
      user.leaves.each do |leave|
        if leave.status == Leave::ROLLBACKED and (leave.leave_type == Leave::CASUAL or leave.leave_type == Leave::MEDICAL)
          return true
        end
      end
    end
    false
  end
end
