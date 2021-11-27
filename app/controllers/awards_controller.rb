class AwardsController < ApplicationController
  authorize_resource

  def index
    @awards = Award.joins(question: :best_answer).where(answers: { author: current_user })
  end
end
