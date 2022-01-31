class KpiItem < ActiveRecord::Base
    belongs_to :kpi_template

    validates :kpi_template, presence: true
    validates :title, presence: true
end
