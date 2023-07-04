class CreateChipResults < ActiveRecord::Migration[6.1]
  def change
    create_table :chip_results do |t|
      t.references :match_group, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :number, null: false
      t.float :point, null: false
      t.boolean :is_temporary, null: false, default: false

      t.timestamps
    end
  end
end
