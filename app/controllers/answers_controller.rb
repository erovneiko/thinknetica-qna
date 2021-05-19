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
    @answer.files.attach answer_params[:files]
    @answer.update(body: answer_params[:body])
    render :update
  end

  def best
    return head(:forbidden) unless current_user.author_of?(@question)

    @answer.is_the_best
    render :update
  end

  def delete_file
    @file = ActiveStorage::Attachment.find(params[:id])
    answer = Answer.find(@file.record_id)

    return head(:forbidden) unless current_user.author_of?(answer)

    @file.purge
  end

  private

  def find_answer
    @answer = Answer.with_attached_files.find(params[:id])
    @question = @answer.question
  end

  def check_author
    head(:forbidden) unless current_user.author_of?(@answer)
  end

  def find_question
    @question = Question.with_attached_files.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body, files: [])
  end
end
