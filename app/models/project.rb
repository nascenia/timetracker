class Project < ApplicationRecord
  has_many :timesheets
  has_and_belongs_to_many :users

  scope :active, -> { where(status: true).order(name: :asc) }
  scope :inactive, -> { where(status: false).order(name: :asc) }
end
