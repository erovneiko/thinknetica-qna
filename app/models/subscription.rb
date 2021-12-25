class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscriptable, polymorphic: true
end
