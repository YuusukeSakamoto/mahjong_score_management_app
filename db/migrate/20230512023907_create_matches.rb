class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.references :player, null: false, foreign_key: true
      t.references :rule, null: false, foreign_key: true
      t.integer :play_type, null: false
      t.date :match_on
      t.string :memo

      t.timestamps
    end
  end
end
