class CreateShareLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :share_links do |t|
      t.string :token, null: false
      t.references :user, foreign_key: true
      t.integer :resource_type, null: false
      t.integer :resource_id, null: false
      t.timestamps
    end
    add_index :share_links, :token, unique: true
    add_index :share_links, [:resource_type, :resource_id]
  end
end

