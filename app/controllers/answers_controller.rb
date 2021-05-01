class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_answer, only: [:destroy, :update, :best]
  before_action :check_author, only: [:destroy, :update]
  before_action :find_question, only: [:create]

  def create
    @answer = @question.answers.new(answer_params)
    @answer.author = current_user
    @answer.save
  end

  def destroy
    Answer.transaction do
      @answer.question.update(best_answer: nil) if @answer.is_the_best?
      @answer.destroy
    end
    render :update
  end

  def update
    @answer.update(answer_params)
    render :update
  end

  def best
    return head(:forbidden) unless current_user.author_of?(@question)

    @answer.is_the_best
    render :update
  end

  private

  def find_answer
    @answer = Answer.find(params[:id])
    @question = @answer.question
  end

  def check_author
    head(:forbidden) unless current_user.author_of?(@answer)
  end

  def find_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
