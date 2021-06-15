class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :load_question, only: [:show, :update, :destroy, :vote_up, :vote_down]
  before_action :load_vote, only: [:vote_up, :vote_down]
  before_action :check_author, only: [:destroy, :update]

  def index
    @questions = Question.all
  end

  def show
    if user_signed_in?
      @answer = Answer.new
      @answer.links.new
    end
  end

  def new
    @question = Question.new
    @question.links.new
    @question.award = Award.new
  end

  def create
    @question = Question.new(question_params)
    @question.author = current_user

    if @question.save
      redirect_to questions_path, notice: 'Your question successfully created'
    else
      render :new
    end
  end

  def update
    @question.update(question_params)
    @questions = Question.all
  end

  def destroy
    @question.destroy
    @questions = Question.all
    render :update
  end

  def vote_up
    return head(:forbidden) if current_user.author_of?(@question)

    if @vote
      @vote.update(result: 1) if @vote.result == -1
    else
      Vote.create(user: current_user, votable: @question, result: 1)
    end

    render json: { votes: @question.votes.sum(:result) }
  end

  def vote_down
    return head(:forbidden) if current_user.author_of?(@question)

    if @vote
      @vote.update(result: -1) if @vote.result == 1
    else
      Vote.create(user: current_user, votable: @question, result: -1)
    end

    render json: { votes: @question.votes.sum(:result) }
  end

  private

  def load_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def load_vote
    @vote = Vote.find_by(user: current_user, votable: @question)
  end

  def check_author
    head(:forbidden) unless current_user.author_of?(@question)
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [],
                                     links_attributes: [:id, :name, :url, :_destroy],
                                     award_attributes: [:name, :image])
  end
end
