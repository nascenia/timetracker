class Weekend < ActiveRecord::Base
  has_many :users, dependent: :nullify

  include OffDays

  validates_presence_of :name, message: 'must be provided.'
  validates_presence_of :off_days, message: 'cannot be empty.'

  def self.today? user
    today = Date.today.strftime('%A')
    counter = 0
    user.weekend.off_days.map(&:capitalize).each do |weekend|
      if weekend.to_s == today
        counter += 1
      end
    end
    if counter > 0
    return true
    else return false
    end
  end

end
