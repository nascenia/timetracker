class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    domain = request.env["omniauth.auth"][:info][:email].split('@').last
    if  domain == 'nascenia.com' || domain == 'bdipo.com' || domain == 'gmail.com'
      @user = User.find_for_google_oauth2(request.env["omniauth.auth"])
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