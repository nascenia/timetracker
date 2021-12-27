class KpiTemplate < ActiveRecord::Base
    has_many    :kpi_items

    scope :published, -> { where(published: true) }
end
