class ApplicationController < ActionController::Base
  require 'device_detector'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :request_client_hints
  # before_action :assign_salat_time

  before_action :authenticate_user!
  
  #
  # def assign_salat_time
  #   @salaat = Salaat.all
  # end
  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:has_admin_privilege?)
  end

  private

  def request_client_hints
    response.headers['Accept-CH'] = 'Sec-CH-UA-Platform-Version, Sec-CH-UA-Model, Sec-CH-UA-Mobile, Sec-CH-UA-Platform'
  end

  def get_device_string_from_headers
    # Prefer data from Client Hints
    hint_platform = request.headers['Sec-CH-UA-Platform'].to_s.gsub('"', '')
    hint_version = request.headers['Sec-CH-UA-Platform-Version'].to_s.gsub('"', '')
    hint_model = request.headers['Sec-CH-UA-Model'].to_s.gsub('"', '')

    ua_string_to_parse = ""
    # Use hint_model as the definitive source of truth if available
    if hint_model.present?
      # Construct a synthetic UA string to feed to the gem's database.
      ua_string_to_parse = "Mozilla/5.0 (Linux; Android; #{hint_model}) AppleWebKit/537.36"
    else
      # Fallback to the actual User-Agent for old clients or desktops.
      ua_string_to_parse = request.user_agent
    end
    
    #Rails.logger.info("String being parsed by DeviceDetector: #{ua_string_to_parse.inspect}")
    detector = DeviceDetector.new(ua_string_to_parse)

    # Handle desktops as a special case, as they have no brand/model
    if detector.device_type == 'desktop'
      browser_name = detector.name
      
      # Use hint platform if available, otherwise detector's os_name
      os_name = hint_platform.presence || detector.os_name
      
      # Use hint version if available, otherwise detector's os_full_version
      os_version_string = hint_version.presence || detector.os_full_version

      # Combine browser, OS name, and OS version
      final_string_components = [browser_name, "on", os_name]
      final_string_components << os_version_string if os_version_string.present? # Add version only if available

      final_string = final_string_components.compact.reject(&:empty?).join(' ')
      
      Rails.logger.info("Desktop detected. Final Device String: #{final_string.inspect}")
      return final_string
    end

    # Proceed with mobile/other device logic
    brand = detector.device_brand
    name = detector.device_name

    friendly_name = nil

    # Layer 1: Try to get a friendly name from the gem
    if brand.present? && name.present?
      friendly_name = "#{brand} #{name}"
    end
    
    # Layer 2: If gem fails, try our manual mapping
    if friendly_name.blank? && hint_model.present? && defined?(DEVICE_MODEL_MAP)
      friendly_name = DEVICE_MODEL_MAP[hint_model]
    end
    
    # Layer 3: If all else fails, use the raw model ID from the hint
    friendly_name ||= hint_model.presence

    # Use the most accurate OS info available
    os_name = hint_platform.presence || detector.os_name
    os_version = hint_version.presence || detector.os_full_version
    
    # Construct the final string for mobile/other devices
    final_string = [friendly_name, os_name, os_version].compact.reject(&:empty?).join(' ')
    
    Rails.logger.info("Mobile/Other Device detected. Final Device String: #{final_string.inspect}")
    
    return final_string
  end

end
