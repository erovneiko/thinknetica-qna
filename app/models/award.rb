class Award < ApplicationRecord
  belongs_to :question

  has_one_attached :image, dependent: :destroy

  validates :name, presence: true
  validates :image, attached: true
end
