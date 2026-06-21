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

  def edit
    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = params[:reset_password_token]

    if params[:reset_password_token].present?
      user = resource_class.with_reset_password_token(params[:reset_password_token])
      if user.nil?
        @reset_token_error = 'Reset password token is invalid.'
      elsif !user.reset_password_period_valid?
        @reset_token_error = 'Reset password token has expired.'
      end
    end
  end
end
