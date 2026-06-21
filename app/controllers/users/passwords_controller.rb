class Users::PasswordsController < Devise::PasswordsController
  include Devise::OmniAuth::UrlHelpers
  helper_method :omniauth_authorize_path, :omniauth_callback_path

  layout 'application'

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    errors = resource.errors[:email].any?

    respond_to do |format|
      format.js { render 'devise/passwords/create', locals: { success: !errors } }
      format.html { redirect_to new_user_session_path }
    end
  end
end
