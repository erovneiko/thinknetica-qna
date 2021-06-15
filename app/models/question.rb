class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  has_many_attached :files, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_one :award, dependent: :destroy

  belongs_to :author, class_name: 'User'
  belongs_to :best_answer, class_name: 'Answer', optional: true

  accepts_nested_attributes_for :links, reject_if: :all_blank
  accepts_nested_attributes_for :award, reject_if: :all_blank

  default_scope { order(:title) }

  validates :title, :body, presence: true
end
