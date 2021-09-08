class CommentsChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams

    if params[:question_id]
      Question.find(params[:question_id]).answers.each { |answer| stream_for answer }
    else
      Question.all.each { |question| stream_for question }
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
