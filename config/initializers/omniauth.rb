Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "development"
    provider :google_oauth2, "862145973961-76dddo3vmhj3tosh2grj4u3tlj0sukki.apps.googleusercontent.com", "Ir6vhpKtCxBkhip0uaRqP4XT"
  elsif Rails.env == "staging"
    provider :google_oauth2, "581211922187-na063css1t5ca6a3mutpd1vua9elp52f.apps.googleusercontent.com", "QfYmBr8qQwQQ0M3ZjHmBx2LW"
  end
end