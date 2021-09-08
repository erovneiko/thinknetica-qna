module Voted
  extend ActiveSupport::Concern

  included do
    before_action :load_votable, only: [:vote_up, :vote_down]
    before_action :load_vote, only: [:vote_up, :vote_down]
    before_action :check_votable_author, only: [:vote_up, :vote_down]
  end

  def vote_up
    @vote.up
    render json: { votes: @votable.votes_sum }
  end

  def vote_down
    @vote.down
    render json: { votes: @votable.votes_sum }
  end

  private

  def model_klass
    controller_name.classify.constantize
  end

  def load_votable
    @votable = model_klass.find(params[:id])
  end

  def load_vote
    @vote = Vote.find_by(user: current_user, votable: @votable)
    @vote ||= @votable.votes.build(user: current_user)
  end

  def check_votable_author
    head(:forbidden) if current_user.author_of?(@votable)
  end
end
