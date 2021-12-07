class Goal < ActiveRecord::Base

    STATUSES = ['Pending', 'Approved', 'Completed']

    belongs_to  :goal_category
    belongs_to  :user

    attr_accessor :personal_or_team, :time_period, :team_member
    
    scope :by_date_range, -> (start_date, end_date) { where("start_date >= ? AND end_date <= ?", Date.parse(start_date), Date.parse(end_date)) }

    validates   :title, presence: true
    validates   :point, presence: true, numericality: true


    def self.search(params = {}, user_id)

      return [] if params.blank?
      
      goal = self
      goal = goal.where(user_id: user_id)
      goal = goal.by_date_range(params[:start_date], params[:end_date]) unless params[:start_date].blank? && params[:end_date].blank?
      goal = goal.order(id: :desc)
    end
end
