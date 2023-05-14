class CreateResults < ActiveRecord::Migration[6.1]
  def change
    create_table :results do |t|
      t.references :player, null: false, foreign_key: true
      t.references :rule, null: false, foreign_key: true
      t.date :match_time, null: false
      t.integer :score, null: false
      t.integer :pointeger, null: false
      t.integer :ie, null: false
      t.integer :recorded_player_id, null: false
      t.string :memo

      t.timestamps
    end
  end
end
