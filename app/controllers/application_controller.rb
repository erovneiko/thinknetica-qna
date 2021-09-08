class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :gon_values

  private

  def gon_values
    gon.current_user_id = current_user.id if current_user
    gon.form_auth_token = form_authenticity_token
  end
end
