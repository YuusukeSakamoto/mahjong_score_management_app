class AddPlayerNumnToRule < ActiveRecord::Migration[6.1]
  def change
    add_column :rules, :player_num, :integer, null: false
  end
end
