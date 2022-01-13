class Kpi < ActiveRecord::Base

    STATUSES = { inreview: 0, approved: 1 }

    belongs_to  :user

    attr_accessor :kpi_template_id, :time_period
    
end
