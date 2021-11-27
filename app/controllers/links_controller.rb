class LinksController < ApplicationController
  def destroy
    @link = Link.find(params[:id])
    authorize! :destroy, @link
    @link.destroy
  end
end
