class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :author_id, :title, :body, :created_at, :updated_at
  has_many :answers
  has_many :comments
  has_many :files, serializer: FileSerializer
  has_many :links
end
