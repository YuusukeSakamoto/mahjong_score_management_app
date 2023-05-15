class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.references :player, null: false, foreign_key: true
      t.references :rule, null: false, foreign_key: true
      t.date :match_day
      t.string :memo

      t.timestamps
    end
  end
end
