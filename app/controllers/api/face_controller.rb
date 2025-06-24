class Api::FaceController < ApplicationController
  require 'net/http/post/multipart'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'yaml'
  
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:register, :recognize]
  skip_before_action :verify_authenticity_token, only: [:register, :recognize]
  
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
      
      if face_encoding
        # Update user's face encoding
        user.update(face_encoding: face_encoding)
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
      
      # Validate parameters
      unless image_file.present?
        return render json: { success: false, error: 'Missing image data' }, status: :bad_request
      end

      # Gather all users with a face_encoding
      users_with_encoding = User.where.not(face_encoding: [nil, '']).pluck(:id, :face_encoding)
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
end 