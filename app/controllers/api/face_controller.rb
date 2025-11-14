class Api::FaceController < ApplicationController
  require 'device_detector'
  require 'net/http/post/multipart'
  require 'net/http'
  require 'uri'
  require 'json'
  include AttendanceApiUpdatable
  
  before_action :authenticate_user!
  #skip_before_action :authenticate_user!, only: [:liveness_and_recognition, :register_face]
  skip_before_action :verify_authenticity_token, only: [:liveness_and_recognition, :register_face]

  # POST /api/face/liveness_and_recognition
  def liveness_and_recognition
    begin
      user_agent_string = request.user_agent
      #Rails.logger.info "User Agent String: #{user_agent_string}"
      detector = DeviceDetector.new(user_agent_string)
      #Rails.logger.info "Parsed User Agent with device_detector: #{detector.inspect}"

      device_type = detector.device_type
      brand = detector.device_brand
      model = detector.device_name
      os_info = "#{detector.os_name} #{detector.os_full_version}"
      
      device_model = [brand, model, os_info].compact.reject(&:empty?).join(' ')

      Rails.logger.info "Device Type: #{device_type}, Device Model: #{device_model}"

      action_type = params[:action_type] # 'checkin' or 'checkout'
      if action_type == 'checkin'
        check_in_time = session[:check_in_time]
        if check_in_time.nil? || (Time.zone.now - Time.parse(check_in_time.to_s) > 2.minutes)
          return render json: { success: false, error: 'Check-in time expired. Please try again.' }
        end
      end
      # IP Whitelist Check
      unless Attendance::IP_WHITELIST.include?(request.remote_ip)
        return render json: { success: false, error: 'Check-in or out is restricted from outside office.' }
      end

      # Extract frames and action
      frames = Array.wrap(params[:frames])

      unless frames.present? && frames.size == 3 && ['checkin', 'checkout'].include?(action_type)
        return render json: { success: false, error: 'Missing or invalid parameters' }
      end

      # Call FastAPI service for liveness and recognition
      result = call_fastapi_liveness_and_recognition(frames, current_user.id)

      if result && result['success'] && result['user_id'].to_s == current_user.id.to_s
        # Face verified, now perform the attendance action securely
        begin
          message = ''
          attendance = nil
          if action_type == 'checkin'
            # Logic adapted from AttendancesController#create
            existing_attendance = current_user.attendances.where(checkin_date: Date.today).last
            if existing_attendance.present? && existing_attendance.out_time.blank?
              message = 'You are already checked in.'
            else
              attendance = Attendance.create_attendance(current_user.id, existing_attendance, check_in_time)
              if attendance
                attendance.update(checkin_device: device_model)
              end
              session.delete(:check_in_time)
              message = 'Successfully checked in.'
            end
          elsif action_type == 'checkout'
            # Logic adapted from AttendancesController#update
            attendance = current_user.attendances.where(checkin_date: Date.today, out_time: nil).last
            if attendance
              # Ensure timesheet is filled if required (simplified check)
              if Timesheet.where(user_id: current_user.id, date: Date.today).exists?
                attendance.update(out_time: Time.zone.now.to_s(:time), checkout_device: device_model)
                total_hours = ((attendance.out_time.to_time - attendance.in_time.to_time) / 1.hour).round(2)
                attendance.update(total_hours: total_hours)
                message = nil # No message on successful checkout
              else
                # Timesheet is not filled. Set session flags to remember the checkout intent.
                session[:is_from_checkout] = 1
                session[:attendence_id] = attendance.id
                session[:log_id] = result['log_id']
                # Instruct the client to redirect to the timesheet page.
                return render json: { success: true, action: 'redirect', url: new_timesheet_path }
              end
            else
              message = 'You have not checked in today.'
            end
          end

          # If an attendance record was created or updated, notify the FastAPI service
          if attendance && attendance.id.present?
            log_id = result['log_id']
            #Rails.logger.info "log id: #{log_id}  attendance_id: #{attendance.id}"
            call_update_attendance_api(log_id, attendance.id)
            file_path = save_facial_capture(frames[1], current_user, attendance, action_type)
            if file_path
              if action_type == 'checkin'
                attendance.update(checkin_image: file_path)
              elsif action_type == 'checkout'
                attendance.update(checkout_image: file_path)
              end
            end
          end

          render json: { success: true, message: message, user_name: current_user.name }
        rescue => e
          Rails.logger.error "Attendance action failed after face verification: #{e.message}"
          render json: { success: false, error: 'Could not record attendance. Please try again.' }
        end
      else
        Rails.logger.error "Recognition or liveness failed. Result: #{result.inspect}"
        render json: result || { success: false, error: 'Recognition or liveness failed' }
      end
    rescue => e
      Rails.logger.error "internal server Error: #{e.message}"
      render json: { success: false, error: 'Internal server error' }
    end
  end
  
  def register_face
    begin
      # Validate input
      unless params[:image].present? && params[:user_id].present?
        return render json: { success: false, error: 'Missing required parameters' }
      end

      # Prepare data for FastAPI
      result = call_fastapi_register_face(params[:image], params[:user_id])

      if result && result['success']
        user = User.find_by(id: params[:user_id])
        if user
          user.registered_face = params[:image]
          user.save!
        end
        render json: { success: true }
      else
        render json: result || { success: false, error: 'Face registration failed' }
      end
    rescue => e
      Rails.logger.error "Face registration error: #{e.message}"
      render json: { success: false, error: 'Internal server error' }
    end
  end

  private

  def save_facial_capture(frame, user, attendance, action_type)
    return nil unless frame.present?
  
    begin
      user_name = user.name.parameterize
      timestamp = Time.current.strftime('%Y%m%d%H%M%S')
      attendance_id = attendance.id
  
      dir_path = Rails.root.join('public', 'attendance_facials', user_name, action_type)
      FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
  
      file_name = "#{user.id}_#{timestamp}_#{attendance_id}.jpg"
      file_path = File.join(dir_path, file_name)
  
      # Rewind the frame's tempfile to ensure we can read it from the beginning
      frame.rewind
  
      File.open(file_path, 'wb') do |file|
        file.write(frame.read)
      end
  
      Rails.logger.info "Saved facial capture to #{file_path}"
      return file_path.to_s.gsub(Rails.root.join('public').to_s, '')
    rescue => e
      Rails.logger.error "Failed to save facial capture: #{e.message}"
      return nil
    end
  end

  def call_fastapi_liveness_and_recognition(frames, user_id = nil)
    face_check_in_api = CONFIG['face_check_in_api']
    uri = URI(face_check_in_api)
    files = {}
    files["frames"] = frames.map do |frame|
      UploadIO.new(frame.tempfile, frame.content_type, frame.original_filename)
    end
    request = Net::HTTP::Post::Multipart.new(
      uri.path,
      files.merge({
        'user_id' => user_id
      })
    )
    request['Authorization'] = "Bearer #{ENV['FASTAPI_API_KEY']}" if ENV['FASTAPI_API_KEY']
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.request(request)
    if response.body.present?
      JSON.parse(response.body)
    end
  end

  def call_fastapi_register_face(image, user_id)
    uri = URI(CONFIG['face_registration_api'])
    form_data = {
      'image' => UploadIO.new(image.tempfile, image.content_type, image.original_filename),
      'user_id' => user_id,
    }
    request = Net::HTTP::Post::Multipart.new(uri.path, form_data)
  
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.request(request)
  
    if response.body.present?
      JSON.parse(response.body)
    end
  end
end
