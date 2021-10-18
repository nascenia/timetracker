Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, CONFIG['google_oauth2']['client_id'], CONFIG['google_oauth2']['client_secret']
end
