class Api::FaceController < ApplicationController
  require 'net/http/post/multipart'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'yaml'
  
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:liveness_and_recognition, :register_face]
  skip_before_action :verify_authenticity_token, only: [:liveness_and_recognition, :register_face]
  
  # POST /api/face/liveness_and_recognition
  def liveness_and_recognition
    begin
      # Extract frames (array of images) and device_type
      frames = Array.wrap(params[:frames])
      device_type = params[:device_type] || 'pc'
      unless frames.present? && frames.size == 5
        return render json: { success: false, error: 'Missing or insufficient frames' }, status: :bad_request
      end
      # Call FastAPI service for liveness and recognition
      result = call_fastapi_liveness_and_recognition(frames, device_type, (current_user ? current_user.id : nil))
      if result && result['success'] && result['user_id']
        user = User.find(result['user_id'])
        sign_in(user)
        render json: {
          success: true,
          user_id: user.id,
          user_name: user.name,
        }
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
