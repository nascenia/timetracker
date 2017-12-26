module OffDays
  extend ActiveSupport::Concern

  DAYS = [
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
    :sunday
  ].freeze

  included do
    bitmask :off_days, as: [:monday, :tuesday, :wednesday, :thursday,
                            :friday, :saturday, :sunday], null: false

    # For use in form helpers, arranges the days in the display order
    def self.off_day_options
      DAYS.collect { |day| [day, day.to_s.titleize] }
    end
  end
end
