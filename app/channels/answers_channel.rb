class AnswersChannel < ApplicationCable::Channel
  def subscribed
    stream_for Question.find(params[:question_id])
  end
end
