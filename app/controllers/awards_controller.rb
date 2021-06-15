class AwardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @awards = Award.joins(question: :best_answer).where(answers: { author: current_user })
  end
end
