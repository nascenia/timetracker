# app/controllers/concerns/attendance_api_updatable.rb
module AttendanceApiUpdatable
  extend ActiveSupport::Concern

  private

  def call_update_attendance_api(log_id, attendance_id)
    uri = URI(CONFIG['update_attendance_api'])
    request = Net::HTTP::Post.new(uri)
    request.body = { log_id: log_id, attendance_id: attendance_id }.to_json
    request['Content-Type'] = 'application/json'

    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(request)

    if response.code == '200'
      JSON.parse(response.body)
    else
      Rails.logger.error "Failed to update attendance: #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Error calling update_attendance API: #{e.message}"
    nil
  end
end
