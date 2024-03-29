class Question < ApplicationRecord
  include Votable

  belongs_to :author, class_name: 'User'

  has_many :answers, dependent: :destroy
  belongs_to :best_answer, class_name: 'Answer', optional: true

  has_many_attached :files, dependent: :destroy

  has_many :links, dependent: :destroy, as: :linkable
  accepts_nested_attributes_for :links, reject_if: :all_blank

  has_one :award, dependent: :destroy
  accepts_nested_attributes_for :award, reject_if: :all_blank

  has_many :comments, dependent: :destroy, as: :commentable

  has_many :subscriptions, as: :subscriptable, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  default_scope { order(:title) }

  validates :title, :body, presence: true
end
