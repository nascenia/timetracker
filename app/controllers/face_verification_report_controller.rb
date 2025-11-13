class FaceVerificationReportController < ApplicationController
  before_action :authenticate_user!
  layout 'time_tracker'

  def index
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @limit = 20
    skip = (@page - 1) * @limit

    begin
      response = HTTParty.get("#{URI(CONFIG['face_score_api'])}/?skip=#{skip}&limit=#{@limit}")
      if response.success?
        parsed_response = JSON.parse(response.body)
        Rails.logger.info("Parsed response: #{parsed_response.inspect}")

        if parsed_response.is_a?(Array)
          checkins_data = parsed_response
          total_count = parsed_response.length
        else
          checkins_data = parsed_response['checkins'] || []
          total_count = parsed_response['total'] || 0
        end

        @entries = Kaminari.paginate_array(checkins_data, total_count: total_count).page(@page).per(@limit)

        user_ids = @entries.map { |c| c['user_id'] }.uniq
        @users = User.where(id: user_ids).index_by(&:id)

        attendance_ids = @entries.map { |c| c['attendance_id'] }.compact.uniq
        @attendances = Attendance.where(id: attendance_ids).index_by(&:id)
      else
        @entries = Kaminari.paginate_array([], total_count: 0).page(@page).per(@limit)
        @error = "Failed to fetch data from API. Status code: #{response.code}"
      end
    rescue HTTParty::Error, Errno::ECONNREFUSED => e
      @entries = Kaminari.paginate_array([], total_count: 0).page(@page).per(@limit)
      @error = "Failed to connect to API: #{e.message}"
    end
  end
end
