class Project < ActiveRecord::Base
    has_many :timesheets
    has_and_belongs_to_many :users
end
