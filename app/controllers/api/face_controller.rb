class Api::FaceController < ApplicationController
  require 'net/http/post/multipart'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'yaml'
  
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:register, :recognize, :sign_in_user, :liveness_and_recognition]
  skip_before_action :verify_authenticity_token, only: [:register, :recognize, :sign_in_user, :liveness_and_recognition]
  
  # POST /api/face/register
  def register
    begin
      # Extract image file from request
      image_file = params[:image]
      user_id = params[:user_id]
      
      # Validate parameters
      unless image_file.present? && user_id.present?
        return render json: { success: false, error: 'Missing image or user_id' }, status: :bad_request
      end
      
      # Find user
      user = User.find(user_id)
      unless user == current_user
        return render json: { success: false, error: 'Unauthorized' }, status: :unauthorized
      end
      
      # Call FastAPI service to process face and get encoding
      face_encoding = call_fastapi_register(image_file, user_id)
      device_type = params[:device_type]
      if face_encoding
        # Update user's face encoding in the correct column
        if device_type == 'mb'
          user.update(face_encoding_mb: face_encoding)
        else
          user.update(face_encoding_pc: face_encoding)
        end
        expire_face_user_list_cache # Expire cache after registration
        render json: { success: true, message: 'Face registered successfully' }
      else
        render json: { success: false, error: 'Failed to process face image' }, status: :unprocessable_entity
      end
      
    rescue => e
      Rails.logger.error "Face registration error: #{e.message}"
      render json: { success: false, error: 'Internal server error' }, status: :internal_server_error
    end
  end
  
  # POST /api/face/recognize
  def recognize
    begin
      # Extract image file from request
      image_file = params[:image]
      device_type = params[:device_type] || 'pc'  # Default to pc if not specified
      # Validate parameters
      unless image_file.present?
        return render json: { success: false, error: 'Missing image data' }, status: :bad_request
      end

      # Determine which column to use based on device type
      encoding_column = device_type == 'mb' ? 'face_encoding_mb' : 'face_encoding_pc'
      
      # Gather all users with a face_encoding in the appropriate column
      users_with_encoding = User.where.not(encoding_column => [nil, '']).pluck(:id, encoding_column)
      Rails.logger.info "number of users with encoding: #{users_with_encoding.count}"
      user_list = users_with_encoding.map do |id, encoding|
        arr = if encoding.is_a?(Array)
          encoding
        else
          begin
            JSON.parse(encoding)
          rescue
            begin
              YAML.safe_load(encoding)
            rescue
              []
            end
          end
        end
        { user_id: id, face_encoding: arr }
      end.select { |u| u[:face_encoding].is_a?(Array) && u[:face_encoding].any? }

      if user_list.empty?
        return render json: { success: false, error: 'No registered faces in the system.' }, status: :unprocessable_entity
      end

      # Call FastAPI service to recognize face
      recognition_result = call_fastapi_recognize(image_file, user_list)
      
      if recognition_result && recognition_result[:user_id]
        user = User.find(recognition_result[:user_id])
        Rails.logger.info "Face recognition: matched user=#{user.name}, confidence=#{recognition_result[:confidence]}"
        render json: { 
          success: true, 
          user_id: user.id,
          user_name: user.name,
          confidence: recognition_result[:confidence]
        }
      else
        render json: { success: false, error: 'Face not recognized' }, status: :not_found
      end
      
    rescue => e
      Rails.logger.error "Face recognition error: #{e.message}"
      render json: { success: false, error: 'Internal server error' }, status: :internal_server_error
    end
  end
  
  # POST /api/face/sign_in_user
  def sign_in_user
    begin
      user_id = params[:user_id] || (request.body.present? ? JSON.parse(request.body.read)["user_id"] : nil)
      user = User.find_by(id: user_id)
      unless user
        return render json: { success: false, error: 'User not found' }, status: :not_found
      end
      sign_in(user)
      render json: { success: true, redirect_path: root_path, user_id: user.id, user_name: user.name }
    rescue => e
      Rails.logger.error "Face sign-in error: #{e.message}"
      render json: { success: false, error: 'Internal server error' }, status: :internal_server_error
    end
  end
  
  # POST /api/face/liveness_and_recognition
  def liveness_and_recognition
    begin
      # Extract frames (array of images) and device_type
      frames = Array.wrap(params[:frames])
      device_type = params[:device_type] || 'pc'
      unless frames.present? && frames.size == 5
        return render json: { success: false, error: 'Missing or insufficient frames' }, status: :bad_request
      end
      # Use cached user list
      user_list = cached_user_list(device_type)
      if user_list.empty?
        return render json: { success: false, error: 'No registered faces in the system.' }, status: :unprocessable_entity
      end
      # Call FastAPI service for liveness and recognition
      result = call_fastapi_liveness_and_recognition(frames, user_list, device_type)
      if result && result['success'] && result['user_id']
        user = User.find(result['user_id'])
        render json: {
          success: true,
          user_id: user.id,
          user_name: user.name,
          confidence: result['confidence'],
          liveness_score: result['liveness_score'],
          is_live: result['is_live']
        }
      else
        render json: result || { success: false, error: 'Recognition or liveness failed' }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Liveness+Recognition error: #{e.message}"
      render json: { success: false, error: 'Internal server error' }, status: :internal_server_error
    end
  end
  
  private
  
  def call_fastapi_register(image_file, user_id)
    fastapi_url = ENV['FASTAPI_URL'] || 'http://localhost:8000'
    uri = URI("#{fastapi_url}/register_face")
    
    request = Net::HTTP::Post::Multipart.new(
      uri.path,
      {
        'image' => UploadIO.new(image_file.tempfile, image_file.content_type, image_file.original_filename),
        'user_id' => user_id.to_s
      }
    )
    request['Authorization'] = "Bearer #{ENV['FASTAPI_API_KEY']}" if ENV['FASTAPI_API_KEY']
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.request(request)
    
    if response.code == '200'
      result = JSON.parse(response.body)
      return result['face_encoding'] if result['success']
    end
    Rails.logger.error "FastAPI register error: #{response.code} - #{response.body}"
    nil
  end
  
  def call_fastapi_recognize(image_file, user_list)
    fastapi_url = ENV['FASTAPI_URL'] || 'http://localhost:8000'
    uri = URI("#{fastapi_url}/recognize_face")

    require 'json'
    require 'net/http/post/multipart'
    request = Net::HTTP::Post::Multipart.new(
      uri.path,
      {
        'image' => UploadIO.new(image_file.tempfile, image_file.content_type, image_file.original_filename),
        'users' => user_list.to_json
      }
    )
    request['Authorization'] = "Bearer #{ENV['FASTAPI_API_KEY']}" if ENV['FASTAPI_API_KEY']

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.request(request)

    if response.code == '200'
      result = JSON.parse(response.body)
      if result['success']
        return {
          user_id: result['user_id'],
          confidence: result['confidence']
        }
      end
    end
    Rails.logger.error "FastAPI recognize error: #{response.code} - #{response.body}"
    nil
  end

  def call_fastapi_liveness_and_recognition(frames, user_list, device_type)
    fastapi_url = ENV['FASTAPI_URL'] || 'http://localhost:8000'
    uri = URI("#{fastapi_url}/liveness_and_recognition")
    require 'net/http/post/multipart'
    require 'json'
    frames = Array.wrap(frames)
    files = {}
    files["frames"] = frames.map do |frame|
      UploadIO.new(frame.tempfile, frame.content_type, frame.original_filename)
    end
    request = Net::HTTP::Post::Multipart.new(
      uri.path,
      files.merge({
        'users' => user_list.to_json,
        'device_type' => device_type
      })
    )
    request['Authorization'] = "Bearer #{ENV['FASTAPI_API_KEY']}" if ENV['FASTAPI_API_KEY']
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.request(request)
    if response.code == '200'
      JSON.parse(response.body)
    else
      Rails.logger.error "FastAPI liveness_and_recognition error: #{response.code} - #{response.body}"
      nil
    end
  end

  def cached_user_list(device_type)
    cache_key = "face_user_list_#{device_type}"
    Rails.cache.fetch(cache_key) do
      encoding_column = device_type == 'mb' ? 'face_encoding_mb' : 'face_encoding_pc'
      users_with_encoding = User.where.not(encoding_column => [nil, '']).pluck(:id, encoding_column)
      users_with_encoding.map do |id, encoding|
        arr = if encoding.is_a?(Array)
          encoding
        else
          begin
            JSON.parse(encoding)
          rescue
            begin
              YAML.safe_load(encoding)
            rescue
              []
            end
          end
        end
        { user_id: id, face_encoding: arr }
      end.select { |u| u[:face_encoding].is_a?(Array) && u[:face_encoding].any? }
    end
  end

  def expire_face_user_list_cache
    Rails.cache.delete("face_user_list_pc")
    Rails.cache.delete("face_user_list_mb")
  end
end 