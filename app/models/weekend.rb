class Weekend < ApplicationRecord
  has_one :pre_registration, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :exclusion_dates, as: :excluded, dependent: :destroy

  include OffDays

  validates :name, presence: true
  validates :off_days, presence: false

  def self.today?(user)
    user.weekend.off_days.map(&:capitalize).map(&:to_s).include? Date.today.strftime('%A') if user.weekend
  end

  def self.excluded?(user)
    user.weekend.exclusion_dates.pluck(:date).include? Date.today if user.weekend
  end
end
