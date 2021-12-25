class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscriptable, polymorphic: true, null: false
      t.index %i[user_id subscriptable_type subscriptable_id], name: 'index_user_subscription'
      t.index %i[subscriptable_type subscriptable_id user_id], name: 'index_subscription_user'

      t.timestamps
    end
  end
end
