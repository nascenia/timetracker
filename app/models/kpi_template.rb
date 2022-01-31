class KpiTemplate < ActiveRecord::Base
    has_many    :kpi_items
    has_many    :users
    
    scope :published, -> { where(published: true) }

    validates   :title, presence: true, uniqueness: true
end
