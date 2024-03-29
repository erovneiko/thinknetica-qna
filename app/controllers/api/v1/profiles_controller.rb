class Api::V1::ProfilesController < Api::V1::BaseController
  authorize_resource class: User

  def me
    render json: current_resource_owner
  end

  def index
    render json: User.all.where.not(id: current_resource_owner.id)
  end
end 
