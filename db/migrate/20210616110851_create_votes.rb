class CreateVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :votable, polymorphic: true, null: false
      t.integer :result, default: 0, null: false
      t.index [:user_id, :votable_type, :votable_id]

      t.timestamps
    end
  end
end
