class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, :all
      cannot :create, Comment do |comment|
        comment.commentable.author_id == user.id
      end
    else
      can :read, :all
      cannot :read, Award
    end
  end
end
