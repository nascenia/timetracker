class Weekend < ActiveRecord::Base
  has_many :users, dependent: :nullify

  include OffDays
end
