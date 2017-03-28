class Weekend < ActiveRecord::Base
  has_many :users, dependent: :nullify

  include OffDays

  validates_presence_of :name, message: 'must be provided.'
  validates_presence_of :off_days, message: 'cannot be empty.'
end
