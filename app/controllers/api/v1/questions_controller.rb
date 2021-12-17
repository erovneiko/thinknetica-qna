class Api::V1::QuestionsController < Api::V1::BaseController
  before_action :load_question, only: %i[show update destroy]

  authorize_resource

  def index
    render json: Question.all, each_serializer: QuestionsSerializer
  end

  def show
    render json: @question, serializer: QuestionSerializer
  end

  def create
    @question = Question.new(question_params)
    @question.author = current_resource_owner

    authorize! :create, @question

    if @question.save
      render json: @question.as_json(only: :id, root: true), status: :created
    else
      render json: { errors: @question.errors }, status: :bad_request
    end
  end

  def update
    if @question.update(question_params)
      head :accepted
    else
      render json: { errors: @question.errors }, status: :bad_request
    end
  end

  def destroy
    @question.destroy
    head :ok
  end

  private

  def load_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit!
  end
end
