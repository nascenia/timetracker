class Kpi < ActiveRecord::Base

    STATUSES = { draft: 0, review_request: 1, reviewed: 2, completed: 3 }
    QUATERS   = [
      { start_month: 1, end_month: 3 }, 
      { start_month: 4, end_month: 6 }, 
      { start_month: 7, end_month: 9 },
      { start_month: 10, end_month: 12 }
    ]

    belongs_to  :user

    attr_accessor :personal_or_team, :kpi_template_id, :team_member, :year, :time_period

    validates :user, presence: true
    validates :start_date, presence: true
    validates :end_date, presence: true

    scope :by_date_range, -> (start_date, end_date) { 
      where("start_date >= ? AND end_date <= ?", Date.parse(start_date), Date.parse(end_date)) 
    }

    def draft?
      self.status.eql?(STATUSES[:draft])
    end

    def review_request?
      self.status.eql?(STATUSES[:review_request])
    end

    def reviewed?
      self.status.eql?(STATUSES[:reviewed])
    end

    def completed?
      self.status.eql?(STATUSES[:completed])
    end

    def score
      kpi = self
      score = 0
      data  = JSON.parse(kpi.data)
      score = (data.sum { |kpi| kpi["score"] } / data.size).round(2)
      score
    end

    def self.search(params = {}, user_id)
      return [] if user_id.blank?
      
      kpi = self
      kpi = kpi.where(user_id: user_id)
      return kpi if params.blank?

      unless params.blank?
        kpi = kpi.by_date_range(params[:start_date], params[:end_date]) unless params[:start_date].blank? && params[:end_date].blank?
      end
      
      kpi = kpi.order(start_date: :desc)
    end
end
