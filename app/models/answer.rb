class Answer < ApplicationRecord
  belongs_to :question, required: true
  belongs_to :author, class_name: 'User'

  validates :body, presence: true

  def is_the_best
    question.update(best_answer: self)
  end

  def is_the_best?
    question.best_answer.id == id
  end
end
