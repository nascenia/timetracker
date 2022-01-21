class Kpi < ActiveRecord::Base

    STATUSES = { inreview: 0, approved: 1 }
    QUATERS   = [
      { start_month: 1, end_month: 3 }, 
      { start_month: 4, end_month: 6 }, 
      { start_month: 7, end_month: 9 },
      { start_month: 10, end_month: 12 }
    ]

    belongs_to  :user

    attr_accessor :personal_or_team, :kpi_template_id, :team_member, :year, :time_period

    scope :by_date_range, -> (start_date, end_date) { 
      where("start_date >= ? AND end_date <= ?", Date.parse(start_date), Date.parse(end_date)) 
    }

    def score
      kpi = self
      score = 0
      data  = JSON.parse(kpi.data)
      score = (data.sum { |kpi| kpi["score"] } / data.size).round(2)
      score
    end

    def self.search(params = {}, user_id)
      return [] if user_id.blank? && params.blank?
      
      kpi = self
      kpi = kpi.where(user_id: user_id)
      unless params.blank?
        kpi = kpi.by_date_range(params[:start_date], params[:end_date]) unless params[:start_date].blank? && params[:end_date].blank?
      end
      kpi = kpi.order(id: :desc)
    end
end
