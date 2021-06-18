class FilesController < ApplicationController
  def destroy
    @file = ActiveStorage::Attachment.find(params[:id])

    return head(:forbidden) unless current_user.author_of?(@file.record)

    @file.purge
  end
end
