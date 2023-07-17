class CreateLeagues < ActiveRecord::Migration[6.1]
  def change
    create_table :leagues do |t|
      t.references :player, null: false, foreign_key: true
      t.references :rule, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :play_type, null: false
      t.string :description

      t.timestamps
    end
  end
end
