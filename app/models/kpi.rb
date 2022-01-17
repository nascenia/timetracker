class Kpi < ActiveRecord::Base

    STATUSES = { inreview: 0, approved: 1 }

    belongs_to  :user

    attr_accessor :personal_or_team, :kpi_template_id, :team_member, :time_period

    scope :by_date_range, -> (start_date, end_date) { 
      where("start_date >= ? AND end_date <= ?", Date.parse(start_date), Date.parse(end_date)) 
    }

    def self.search(params = {}, user_id)

      return [] if params.blank?
        
      kpi = self
      kpi = kpi.where(user_id: user_id)
      kpi = kpi.by_date_range(params[:start_date], params[:end_date]) unless params[:start_date].blank? && params[:end_date].blank?
      kpi = kpi.order(id: :desc)
    end
end
