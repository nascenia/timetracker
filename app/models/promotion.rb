class Promotion < ApplicationRecord
  belongs_to :user

  validates :designation, presence: true
  validates :start_date,  presence: true
end
