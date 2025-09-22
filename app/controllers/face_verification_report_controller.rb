class FaceVerificationReportController < ApplicationController
  before_action :authenticate_user!
  layout 'time_tracker'

  def index
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    limit = 20
    skip = (@page - 1) * limit

    begin
      response = HTTParty.get("http://127.0.0.1:8000/all_checkins/?skip=#{skip}&limit=#{limit}")
      if response.success?
        @checkins = JSON.parse(response.body)
        user_ids = @checkins.map { |c| c['user_id'] }.uniq
        @users = User.where(id: user_ids).index_by(&:id)
        @has_next_page = @checkins.length == limit
      else
        @error = "Failed to fetch data from API. Status code: #{response.code}"
      end
    rescue HTTParty::Error, Errno::ECONNREFUSED => e
      @error = "Failed to connect to API: #{e.message}"
    end
  end
end
