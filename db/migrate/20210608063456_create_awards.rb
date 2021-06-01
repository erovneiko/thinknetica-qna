class CreateAwards < ActiveRecord::Migration[6.1]
  def change
    create_table :awards do |t|
      t.string :name
      t.references :question, foreign_key: true, null: false

      t.timestamps
    end
  end
end
