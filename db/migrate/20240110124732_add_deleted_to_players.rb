class AddDeletedToPlayers < ActiveRecord::Migration[6.1]
  def change
    add_column :players, :deleted, :boolean, default: false, null: false
  end
end
