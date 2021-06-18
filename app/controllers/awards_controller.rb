class AwardsController < ApplicationController
  def index
    @awards = Award.joins(question: :best_answer).where(answers: { author: current_user })
  end
end
