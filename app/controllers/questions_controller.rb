class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :load_question, only: [:show, :update, :destroy]

  def index
    @questions = Question.all
  end

  def show
    @answer = Answer.new if user_signed_in?
  end

  def new
    @question = Question.new
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
    return head(:forbidden) unless current_user.author_of?(@question)

    @question.files.attach question_params[:files]
    @question.update(title: question_params[:title], body: question_params[:body])
    @questions = Question.all
  end

  def destroy
    return head(:forbidden) unless current_user.author_of?(@question)

    @question.destroy
    @questions = Question.all
    render :update
  end

  def delete_file
    @file = ActiveStorage::Attachment.find(params[:id])
    question = Question.find(@file.record_id)

    return head(:forbidden) unless current_user.author_of?(question)

    @file.purge
  end

  private

  def load_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [])
  end
end
