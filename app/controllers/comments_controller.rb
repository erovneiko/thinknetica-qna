class CommentsController < ApplicationController
  before_action :load_commentable, only: %i[new create]
  after_action :publish_comment, only: :create

  authorize_resource

  def new
    @comment = @commentable.comments.new
    authorize! :create, @comment
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.author = current_user

    authorize! :create, @comment

    if @comment.save
      if @commentable.instance_of?(Answer)
        redirect_to question_path(@commentable.question)
      else
        redirect_to questions_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  
  def publish_comment
    return if @comment.errors.any?

    channel = if @commentable.instance_of?(Answer)
                "questions/#{@commentable.question.id}/comments"
              else
                'questions/comments'
              end

    ActionCable.server.broadcast channel, {
      action: action_name,
      id: @comment.id,
      body: @comment.body,
      author: {
        id: @comment.author.id,
        email: @comment.author.email
      },
      ref: "#{@comment.commentable_type.downcase}-#{@comment.commentable_id}"
    }
  end

  def load_commentable
    @commentable = if params[:question_id]
                     Question.find(params[:question_id])
                   elsif params[:answer_id]
                     Answer.find(params[:answer_id])
                   end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
