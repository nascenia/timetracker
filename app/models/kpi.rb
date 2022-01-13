class Kpi < ActiveRecord::Base

    STATUSES = { inreview: 0, approved: 1 }

    belongs_to  :user

    attr_accessor :kpi_template_id, :team_member, :time_period
    
    scope :date_range, -> (start_date, end_date) { where("start_date >= ? AND end_date <= ?", Date.parse(start_date), Date.parse(end_date)) }
end
