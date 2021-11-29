module Voted
  extend ActiveSupport::Concern

  included do
    before_action :load_votable, only: %i[vote_up vote_down]
    before_action :load_vote, only: %i[vote_up vote_down]
  end

  def vote_up
    authorize! :vote, @votable
    @vote.up
    render json: { votes: @votable.votes_sum }
  end

  def vote_down
    authorize! :vote, @votable
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
end
