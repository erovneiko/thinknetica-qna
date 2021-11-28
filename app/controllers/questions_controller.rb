class QuestionsController < ApplicationController
  include Voted
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :load_question, only: [:show, :update, :destroy]
  after_action :publish_question, only: [:create]

  authorize_resource

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

  private

  def publish_question
    return if @question.errors.any?

    ActionCable.server.broadcast 'Questions', {
      action: action_name,
      question: {
        id: @question.id,
        title: @question.title,
        body: @question.body,
        author: {
          id: @question.author.id,
          email: @question.author.email
        },
        files: @question.files.map { |file| {
          id: file.id,
          name: file.filename,
          url: url_for(file)
        } },
        links: @question.links.map { |link| {
          id: link.id,
          name: link.name,
          url: link.url,
          gist: link.gist?
        } },
        votes_sum: @question.votes_sum,
        path: "/questions/#{@question.id}",
        name: 'question'
      }
    }
  end

  def load_question
    @question = Question.with_attached_files.find(params[:id])
    gon.question_id = @question.id
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [],
                                     links_attributes: [:id, :name, :url, :_destroy],
                                     award_attributes: [:name, :image])
  end
end
