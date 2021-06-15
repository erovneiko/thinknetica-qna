class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true

  validates :name, presence: true
  validates :url, presence: true, url: true

  def gist?
    url =~ /^https:\/\/gist\.github\.com\/\w+\/\w{32}$/;
  end
end
