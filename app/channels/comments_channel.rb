class CommentsChannel < ApplicationCable::Channel
  def subscribed
    if params[:question_id]
      stream_from "questions/#{params[:question_id]}/comments"
    else
      stream_from 'questions/comments'
    end
  end
end
