class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :updated_at

  # has_many :questions, foreign_key: 'author_id', dependent: :destroy
  # has_many :answers, foreign_key: 'author_id', dependent: :destroy
  # has_many :votes
  # has_many :authorizations, dependent: :destroy
end
