class CreateResults < ActiveRecord::Migration[6.1]
  def change
    create_table :results do |t|
      t.references :match, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :score, null: false
      t.float :point, null: false
      t.integer :ie, null: false
      t.integer :rank, null: false

      t.timestamps
    end
  end
end
