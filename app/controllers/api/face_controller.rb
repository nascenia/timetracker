class Api::FaceController < ApplicationController
  require 'net/http/post/multipart'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'yaml'
  
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:liveness_and_recognition]
  skip_before_action :verify_authenticity_token, only: [:liveness_and_recognition]
  
  
  
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
      result = call_fastapi_liveness_and_recognition(frames, device_type)
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
      Rails.logger.error "Liveness+Recognition error: #{e.message}"
      render json: { success: false, error: 'Internal server error' }, status: :internal_server_error
    end
  end
  
  

  def call_fastapi_liveness_and_recognition(frames, device_type)
    fastapi_url = ENV['FASTAPI_URL'] || 'http://localhost:8000'
    uri = URI("#{fastapi_url}/liveness_and_recognition")
    require 'net/http/post/multipart'
    require 'json'
    files = {}
    files["frames"] = frames.map do |frame|
      UploadIO.new(frame.tempfile, frame.content_type, frame.original_filename)
    end
    request = Net::HTTP::Post::Multipart.new(
      uri.path,
      files.merge({
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

end
 