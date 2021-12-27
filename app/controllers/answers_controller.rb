class AnswersController < ApplicationController
  include Voted
  before_action :load_answer, only: %i[destroy update best]
  after_action :publish_answer, only: :create
  after_action :notify_subsribers, only: :create

  authorize_resource

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new(answer_params)
    @answer.author = current_user

    authorize! :create, @answer

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
    authorize! :best, @answer
    @answer.is_the_best!
    render :update
  end

  private

  def notify_subsribers
    return if @answer.errors.any?


  end

  def publish_answer
    return if @answer.errors.any?

    AnswersChannel.broadcast_to @question, {
      action: action_name,
      id: @answer.id,
      body: @answer.body,
      is_the_best: @answer.is_the_best?,
      author: {
        id: @answer.author.id,
        email: @answer.author.email
      },
      question: {
        id: @question.id,
        author: {
          id: @question.author.id
        }
      },
      files: @answer.files.map { |file| {
        id: file.id,
        name: file.filename,
        url: url_for(file)
      } },
      links: @answer.links.map { |link| {
        id: link.id,
        name: link.name,
        url: link.url,
        gist: link.gist?
      } },
      votes_sum: @answer.votes_sum,
      path: "/answers/#{@answer.id}",
      name: 'answer'
    }
  end

  def load_answer
    @answer = Answer.with_attached_files.find(params[:id])
    @question = @answer.question
  end

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: [:id, :name, :url, :_destroy])
  end
end
