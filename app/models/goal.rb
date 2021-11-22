class Goal < ActiveRecord::Base

    belongs_to  :goal_category
    belongs_to  :user

    attr_accessor :personal_or_team
    
    validates   :title, presence: true
    validates   :point, presence: true, numericality: true

end
