class Answer < ApplicationRecord
  include Votable

  belongs_to :question, required: true
  belongs_to :author, class_name: 'User'

  has_many_attached :files, dependent: :destroy

  has_many :links, dependent: :destroy, as: :linkable
  accepts_nested_attributes_for :links, reject_if: :all_blank

  has_many :comments, dependent: :destroy, as: :commentable

  validates :body, presence: true

  after_create :after_create_callback

  def is_the_best!
    question.update(best_answer: self)
  end

  def is_the_best?
    question.best_answer&.id == id
  end

  private

  def after_create_callback
    return if self.errors.any?

    question.subscribers.each do |s|
      NotificationsMailer.new_answer(s, self).deliver_later
    end
  end
end
