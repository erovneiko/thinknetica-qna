class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'Questions'
  end
end
