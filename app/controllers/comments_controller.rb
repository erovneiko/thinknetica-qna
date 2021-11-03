class CommentsController < ApplicationController
  before_action :find_commentable, only: [:new, :create]
  before_action :check_commentable_author, only: [:new, :create]
  after_action :publish_comment, only: [:create]

  def new
    @comment = Comment.new
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.author = current_user

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

  def find_commentable
    if params[:question_id]
      @commentable = Question.find(params[:question_id])
    elsif params[:answer_id]
      @commentable = Answer.find(params[:answer_id])
    end
  end

  def check_commentable_author
    head(:forbidden) if current_user.author_of?(@commentable)
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
