class Goal < ActiveRecord::Base

    STATUSES = ['Pending', 'Approved', 'Completed']

    belongs_to :goal_category
    belongs_to :user
    # belongs_to :reviewer

    attr_accessor :personal_or_team, :time_period, :team_member
    
    scope :by_date_range, -> (start_date, end_date) { where("start_date >= ? AND end_date <= ?", Date.parse(start_date), Date.parse(end_date)) }

    validates   :title, presence: true
    validates   :point, presence: true, numericality: true


    def quarter
      start_month = self.start_date.strftime('%m').to_i
      
      start_month / 3
    end

    def self.search(params = {}, user_id, current_user)

      goal = self
      if user_id.present?
        goal = goal.where(user_id: user_id)
      else
        team = User.active.where(ttf: current_user)
        team_member_ids = team.map{|u| u.id}
        goal = goal.where(user_id: team_member_ids)
      end
  
      return goal if params.blank?

      unless params[:start_date].blank? && params[:end_date].blank?
        goal = goal.by_date_range(params[:start_date], params[:end_date]) 
      end

      goal = goal.order(id: :desc)
      goal
    end
end
