class KpiItem < ApplicationRecord
  belongs_to :kpi_template

  validates :title, presence: true
end
