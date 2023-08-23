class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    domain = request.env["omniauth.auth"][:extra][:id_info][:email].split('@').last
    p "request domain: #{domain}"
    
    if Rails.application.config.x.app[:domain_whitelist].include? domain
      @user = User.find_for_google_oauth2(request.env["omniauth.auth"])

      if !@user.nil?
        if @user.persisted?
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
          sign_in_and_redirect @user, :event => :authentication
        else
          session["devise.google_data"] = request.env["omniauth.auth"]
          redirect_to new_user_registration_url and return
        end
      else
        flash[:notice] = "Contact with admin please "
        redirect_to root_path and return
      end
    else
      outside_email = request.env["omniauth.auth"][:extra][:id_info][:email].to_s

      if WhitelistEmail.published.pluck(:email).include? outside_email
        @user = User.find_for_google_oauth2(request.env["omniauth.auth"])
        if !@user.nil?
          if @user.persisted?
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
            sign_in_and_redirect @user, :event => :authentication
          else
            session["devise.google_data"] = request.env["omniauth.auth"]
            redirect_to new_user_registration_url and return
          end
        else
          flash[:notice] = "Email domain must be either 'nascenia.com' or 'bdipo.com'."
          redirect_to root_path
        end
      end
    end
  end
end
