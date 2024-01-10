class CreateMatchGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :match_groups do |t|
      t.integer :play_type, null: false
      t.timestamps
    end
  end
end
