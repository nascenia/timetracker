class Project < ActiveRecord::Base
    has_many :timesheets
    has_and_belongs_to_many :users

    scope :active, -> { where(is_active: true) }
    scope :inactive, -> { where(is_active: false) }
end
