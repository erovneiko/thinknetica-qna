class Answer < ApplicationRecord
  belongs_to :question, required: true

  validates :body, presence: true
end
