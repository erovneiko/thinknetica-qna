class QuestionsSerializer < ActiveModel::Serializer
  attributes :id, :author_id, :title, :body, :created_at, :updated_at, :short_title
  belongs_to :author
  has_many :answers

  def short_title
    object.title.truncate(7)
  end
end
