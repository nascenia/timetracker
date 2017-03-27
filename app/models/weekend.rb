class Weekend < ActiveRecord::Base

  has_many :users



  def self.get_params( params )
    day = Array.new
    day[0] = params['weekend']['saturday'] == '1' ? true : false
    day[1] = params['weekend']['sunday'] == '1' ? true : false
    day[2] = params['weekend']['monday'] == '1' ? true : false
    day[3] = params['weekend']['tuesday'] == '1' ? true : false
    day[4] = params['weekend']['wednesday'] == '1' ? true : false
    day[5] = params['weekend']['thursday'] == '1' ? true : false
    day[6] = params['weekend']['friday'] == '1' ? true : false
    return day
  end

  def self.update_weekend( weekend, params )
    day = get_params params
    weekend.update_attributes( name: params['weekend']['name'],
    saturday: day[0], sunday: day[1], monday: day[2], tuesday: day[3],
    wednesday: day[4], thursday: day[5], friday: day[6] )
  end

  def self.get_weekend_days( weekend_id )
    weekend_days = []
    weekend = Weekend.find(weekend_id)
    weekend.saturday ? weekend_days << 'Saturday' : weekend_days
    weekend.sunday ? weekend_days << 'Sunday' : weekend_days
    weekend.monday ? weekend_days << 'Monday' : weekend_days
    weekend.tuesday ? weekend_days << 'Tuesday' : weekend_days
    weekend.wednesday ? weekend_days << 'Wednesday' : weekend_days
    weekend.thursday ? weekend_days << 'Thursday' : weekend_days
    weekend.friday ? weekend_days << 'Friday' : weekend_days
    weekend_days
  end

end
