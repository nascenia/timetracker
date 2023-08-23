require 'httparty'

class SalaatTimesController < ApplicationController
  layout 'timetracker'

  def index


    url = 'http://api.aladhan.com/timingsByCity?city=Dhaka&country=BD&method=2&school=1'
    response = HTTParty.get(url)
    @salaat_times = response.parsed_response
    time = 0
  end
end