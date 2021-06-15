class Answer < ApplicationRecord
  belongs_to :question, required: true
  belongs_to :author, class_name: 'User'

  has_many_attached :files, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable

  accepts_nested_attributes_for :links, reject_if: :all_blank

  validates :body, presence: true

  def is_the_best
    question.update(best_answer: self)
  end

  def is_the_best?
    question.best_answer&.id == id
  end
end
