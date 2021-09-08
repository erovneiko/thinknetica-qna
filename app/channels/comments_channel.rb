class CommentsChannel < ApplicationCable::Channel
  def subscribed
    if params[:question_id]
      Question.find(params[:question_id]).answers.each { |answer| stream_for answer }
    else
      Question.all.each { |question| stream_for question }
    end
  end
end
