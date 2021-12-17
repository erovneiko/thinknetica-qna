class Api::V1::BaseController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :doorkeeper_authorize!
  protect_from_forgery with: :null_session

  check_authorization

  rescue_from(ActiveRecord::RecordNotFound) { head(:not_found) }

  def current_ability
    @ability ||= Ability.new(current_resource_owner)
  end

  private

  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
