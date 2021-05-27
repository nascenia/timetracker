Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "development"
    provider :google_oauth2, "261859180890-omko6rmcr9equhamir68n3a7c0dn9176.apps.googleusercontent.com", "i52c0WOc1bmuj59C7y0KA3NQ"
  elsif Rails.env == "production"
    provider :google_oauth2, "581211922187-na063css1t5ca6a3mutpd1vua9elp52f.apps.googleusercontent.com", "QfYmBr8qQwQQ0M3ZjHmBx2LW"
  elsif Rails.env == "staging"
    provider :google_oauth2, "581211922187-na063css1t5ca6a3mutpd1vua9elp52f.apps.googleusercontent.com", "QfYmBr8qQwQQ0M3ZjHmBx2LW"
  end
end
