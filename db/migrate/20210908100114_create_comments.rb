class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :body, null: false
      t.belongs_to :commentable, polymorphic: true
      t.belongs_to :author, foreign_key: { to_table: :users }, null: false

      t.timestamps
    end
    remove_foreign_key :questions, :best_answer, to_table: :answers
  end
end
