class AddPlayerNumnToRule < ActiveRecord::Migration[6.1]
  def change
    add_column :rules, :play_type, :integer, null: false
  end
end
