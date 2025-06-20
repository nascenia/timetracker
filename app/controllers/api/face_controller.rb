class Api::FaceController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:register, :recognize]
  
  # POST /api/face/register
  def register
    begin
      # Extract image data from request
      image_data = params[:image]
      user_id = params[:user_id]
      
      # Validate parameters
      unless image_data.present? && user_id.present?
        return render json: { success: false, error: 'Missing image or user_id' }, status: :bad_request
      end
      
      # Find user
      user = User.find(user_id)
      unless user == current_user
        return render json: { success: false, error: 'Unauthorized' }, status: :unauthorized
      end
      
      # Call FastAPI service to process face and get encoding
      face_encoding = call_fastapi_register(image_data, user_id)
      
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
      # Extract image data from request
      image_data = params[:image]
      
      # Validate parameters
      unless image_data.present?
        return render json: { success: false, error: 'Missing image data' }, status: :bad_request
      end
      
      # Call FastAPI service to recognize face
      recognition_result = call_fastapi_recognize(image_data)
      
      if recognition_result && recognition_result[:user_id]
        user = User.find(recognition_result[:user_id])
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
  
  def call_fastapi_register(image_data, user_id)
    # Configuration for FastAPI service
    fastapi_url = ENV['FASTAPI_URL'] || 'http://localhost:8000'
    
    # Prepare request to FastAPI
    uri = URI("#{fastapi_url}/register_face")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{ENV['FASTAPI_API_KEY']}" if ENV['FASTAPI_API_KEY']
    
    # Send image data and user_id to FastAPI
    request.body = {
      image: image_data,
      user_id: user_id
    }.to_json
    
    # Make request
    response = http.request(request)
    
    if response.code == '200'
      result = JSON.parse(response.body)
      return result['face_encoding'] if result['success']
    end
    
    Rails.logger.error "FastAPI register error: #{response.code} - #{response.body}"
    nil
  end
  
  def call_fastapi_recognize(image_data)
    # Configuration for FastAPI service
    fastapi_url = ENV['FASTAPI_URL'] || 'http://localhost:8000'
    
    # Prepare request to FastAPI
    uri = URI("#{fastapi_url}/recognize_face")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{ENV['FASTAPI_API_KEY']}" if ENV['FASTAPI_API_KEY']
    
    # Send image data to FastAPI
    request.body = {
      image: image_data
    }.to_json
    
    # Make request
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