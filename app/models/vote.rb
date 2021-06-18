class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true

  def up
    update(result: 1)
  end

  def down
    update(result: -1)
  end
end
