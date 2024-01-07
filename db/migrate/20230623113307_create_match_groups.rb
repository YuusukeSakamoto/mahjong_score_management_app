class CreateMatchGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :match_groups do |t|
      t.references :rule, null: false, foreign_key: true
      t.references :league, foreign_key: true
      t.integer :play_type, null: false
      t.timestamps
    end
  end
end
