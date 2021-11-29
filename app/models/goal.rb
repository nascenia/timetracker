class Goal < ActiveRecord::Base

    STATUSES = ['Pending', 'Approved', 'Completed']

    belongs_to  :goal_category
    belongs_to  :user

    attr_accessor :personal_or_team, :time_period, :team_member
    
    scope :by_date_range, -> (start_date, end_date) { where("start_date >= ? AND end_date <= ?", Date.parse(start_date), Date.parse(end_date)) }

    validates   :title, presence: true
    validates   :point, presence: true, numericality: true


    def self.search(params = {}, current_user)
        user_id = params.blank? ? current_user.id : params[:user_id]

        goal = self
        goal = goal.where(user_id: user_id)
        unless params.blank? 
            goal = goal.by_date_range(params[:start_date], params[:end_date]) unless params[:start_date].blank? && params[:end_date].blank?
        end
        goal = goal.order(id: :desc)
    end
end
