Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, "581211922187-na063css1t5ca6a3mutpd1vua9elp52f.apps.googleusercontent.com", "QfYmBr8qQwQQ0M3ZjHmBx2LW"
end