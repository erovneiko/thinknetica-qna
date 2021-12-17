class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :gon_values

  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_url, alert: exception.message }
      format.json { head(:forbidden) }
      format.js   { head(:forbidden) }
    end
  end

  private

  def gon_values
    gon.current_user_id = current_user.id if current_user
    gon.form_auth_token = form_authenticity_token
  end
end
