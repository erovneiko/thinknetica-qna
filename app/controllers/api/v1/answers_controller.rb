class Api::V1::AnswersController < Api::V1::BaseController
  before_action :load_answer, only: %i[update destroy]

  authorize_resource

  def show
    render json: Answer.find(params[:id]), serializer: AnswerSerializer
  end

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new(answer_params)
    @answer.author = current_resource_owner

    authorize! :create, @answer

    if @answer.save
      render json: @answer.as_json(only: :id, root: true), status: :created
    else
      render json: { errors: @answer.errors }, status: :bad_request
    end
  end

  def update
    if @answer.update(answer_params)
      head :accepted
    else
      render json: { errors: @answer.errors }, status: :bad_request
    end
  end

  def destroy
    @answer.destroy
    head :ok
  end

  private

  def load_answer
    @answer = Answer.find(params[:id])
    @question = @answer.question
  end

  def answer_params
    params.require(:answer).permit!
  end
end
