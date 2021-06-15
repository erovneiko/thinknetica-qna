class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_answer, only: [:destroy, :update, :best, :vote_up, :vote_down]
  before_action :check_author, only: [:destroy, :update]
  before_action :find_question, only: [:create]
  before_action :load_vote, only: [:vote_up, :vote_down]

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

  def vote_up
    return head(:forbidden) if current_user.author_of?(@answer)

    if @vote
      @vote.update(result: 1) if @vote.result == -1
    else
      Vote.create(user: current_user, votable: @answer, result: 1)
    end

    render json: { votes: @answer.votes.sum(:result) }
  end

  def vote_down
    return head(:forbidden) if current_user.author_of?(@answer)

    if @vote
      @vote.update(result: -1) if @vote.result == 1
    else
      Vote.create(user: current_user, votable: @answer, result: -1)
    end

    render json: { votes: @answer.votes.sum(:result) }
  end

  private

  def find_answer
    @answer = Answer.with_attached_files.find(params[:id])
    @question = @answer.question
  end

  def load_vote
    @vote = Vote.find_by(user: current_user, votable: @answer)
  end

  def check_author
    head(:forbidden) unless current_user.author_of?(@answer)
  end

  def find_question
    @question = Question.with_attached_files.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: [:id, :name, :url, :_destroy])
  end
end
