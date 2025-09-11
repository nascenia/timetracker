class Api::FaceController < ApplicationController
  require 'net/http/post/multipart'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'yaml'
  
  before_action :authenticate_user!
  #skip_before_action :authenticate_user!, only: [:liveness_and_recognition, :register_face]
  skip_before_action :verify_authenticity_token, only: [:liveness_and_recognition, :register_face]
  
  # POST /api/face/liveness_and_recognition
  def liveness_and_recognition
    begin
      # Extract frames, device_type, and action
      frames = Array.wrap(params[:frames])
      device_type = params[:device_type] || 'pc'
      action_type = params[:action_type] # 'checkin' or 'checkout'
      initial_click_time_ms = params[:initial_click_time_ms]

      unless frames.present? && frames.size == 3 && ['checkin', 'checkout'].include?(action_type)
        return render json: { success: false, error: 'Missing or invalid parameters' }, status: :bad_request
      end

      # Call FastAPI service for liveness and recognition
      result = call_fastapi_liveness_and_recognition(frames, device_type, current_user.id)

      if result && result['success'] && result['user_id'].to_s == current_user.id.to_s
        # Face verified, now perform the attendance action securely
        begin
          message = ''
          if action_type == 'checkin'
            # Logic adapted from AttendancesController#create
            attendance = current_user.attendances.where(checkin_date: Date.today).last
            if attendance.present? && attendance.out_time.blank?
              message = 'You are already checked in.'
            else
              initial_click_time = initial_click_time_ms.present? ? Time.zone.at(initial_click_time_ms.to_i / 1000.0) : Time.zone.now
              Attendance.create_attendance(current_user.id, attendance, initial_click_time)
              message = 'Successfully checked in.'
            end
          elsif action_type == 'checkout'
            # Logic adapted from AttendancesController#update
            attendance = current_user.attendances.where(checkin_date: Date.today, out_time: nil).last
            if attendance
              # Ensure timesheet is filled if required (simplified check)
              if Timesheet.where(user_id: current_user.id, date: Date.today).exists?
                attendance.update(out_time: Time.zone.now.to_s(:time))
                total_hours = ((attendance.out_time.to_time - attendance.in_time.to_time) / 1.hour).round(2)
                attendance.update(total_hours: total_hours)
                message = nil # No message on successful checkout
              else
                # Redirect to timesheet page if not filled
                return render json: { success: true, action: 'redirect', url: new_timesheet_path }
              end
            else
              message = 'You have not checked in today.'
            end
          end
          render json: { success: true, message: message, user_name: current_user.name }
        rescue => e
          Rails.logger.error "Attendance action failed after face verification: #{e.message}"
          render json: { success: false, error: 'Could not record attendance. Please try again.' }, status: :internal_server_error
        end
      else
        render json: result || { success: false, error: 'Recognition or liveness failed' }, status: :unprocessable_entity
      end
    rescue => e
      render json: { success: false, error: 'Internal server error' }, status: :internal_server_error
    end
  end
  
  def register_face
    begin
      # Validate input
      unless params[:image].present? && params[:user_id].present?
        return render json: { success: false, error: 'Missing required parameters' }, status: :bad_request
      end

      # Prepare data for FastAPI
      result = call_fastapi_register_face(params[:image], params[:user_id], params[:device_type])

      if result && result['success']
        render json: { success: true }
      else
        render json: result || { success: false, error: 'Face registration failed' }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Face registration error: #{e.message}"
      render json: { success: false, error: 'Internal server error' }, status: :internal_server_error
    end
  end

  private

  def call_fastapi_liveness_and_recognition(frames, device_type, user_id = nil)
    face_check_in_api = CONFIG['face_check_in_api']
    uri = URI(face_check_in_api)
    files = {}
    files["frames"] = frames.map do |frame|
      UploadIO.new(frame.tempfile, frame.content_type, frame.original_filename)
    end
    request = Net::HTTP::Post::Multipart.new(
      uri.path,
      files.merge({
        'device_type' => device_type,
        'user_id' => user_id
      })
    )
    request['Authorization'] = "Bearer #{ENV['FASTAPI_API_KEY']}" if ENV['FASTAPI_API_KEY']
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.request(request)
    if response.code == '200'
      JSON.parse(response.body)
    end
  end

  def call_fastapi_register_face(image, user_id, device_type)
    uri = URI(CONFIG['face_registration_api'])
    form_data = {
      'image' => UploadIO.new(image.tempfile, image.content_type, image.original_filename),
      'user_id' => user_id,
      'device_type' => device_type
    }
    request = Net::HTTP::Post::Multipart.new(uri.path, form_data)
  
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.request(request)
  
    if response.code == '200'
      JSON.parse(response.body)
    end
  end

end
