class Kpi < ActiveRecord::Base
    belongs_to  :user

    attr_accessor :kpi_template_id

    validates :title, presence: true
end
