class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    domain = request.env["omniauth.auth"][:extra][:id_info][:email].split('@').last
    if CONFIG['domain_whitelist'].include? domain
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
        email = request.env["omniauth.auth"][:extra][:id_info][:email].to_s
        @oauth_error_message = "There is no user with this #{email}."
        render 'users/omniauth_callbacks/google_oauth2' and return
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
          @oauth_error_message = "There is no user with this #{outside_email}."
          render 'users/omniauth_callbacks/google_oauth2' and return
        end
      else
        @oauth_error_message = "This #{outside_email} is not whitelisted."
        render 'users/omniauth_callbacks/google_oauth2' and return
      end
    end
  end
end
