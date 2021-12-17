class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user

    if user
      user_abilities
    else
      guest_abilities
    end
  end

  private

  def user_abilities
    can :manage, :all

    cannot [:update, :destroy], [Question, Answer] do |object|
      object.author_id != user.id
    end

    cannot [:update, :destroy], ActiveStorage::Attachment do |file|
      file.record.author_id != user.id
    end

    cannot [:update, :destroy], Link do |link|
      link.linkable.author_id != user.id
    end

    cannot :best, Answer do |answer|
      answer.question.author_id != user.id
    end

    cannot :create, Comment do |comment|
      comment.commentable.author_id == user.id
    end

    cannot :vote, :all do |object|
      object.author_id == user.id
    end
  end

  def guest_abilities
    can :read, :all
    cannot :read, Award
    cannot :vote, :all
  end
end
