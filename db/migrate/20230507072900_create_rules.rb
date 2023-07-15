class CreateRules < ActiveRecord::Migration[6.1]
  def change
    create_table :rules do |t|
      t.references :player, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :mochi, null: false
      t.integer :kaeshi, null: false
      t.integer :uma_1, null: false
      t.integer :uma_2, null: false
      t.integer :uma_3, null: false
      t.integer :uma_4, null: false
      t.integer :score_decimal_point_calc, null: false
      t.boolean :is_chip, default: false, null: false
      t.integer :chip_rate, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
