class SubscriptionsController < ApplicationController
  before_action :load_subscriptable, only: %i[create]
  before_action :load_subscription, only: %i[destroy]

  authorize_resource

  def create
    @subscriptable.subscribers << current_user
    redirect_to :root
  end

  def destroy
    @subscription.destroy
    redirect_to :root
  end

  private

  def load_subscriptable
    @subscriptable = Question.find(params[:question_id]) if params[:question_id]
  end

  def load_subscription
    @subscription = Subscription.find(params[:id])
  end
end
