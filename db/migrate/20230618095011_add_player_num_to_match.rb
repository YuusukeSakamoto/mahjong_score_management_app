class AddPlayerNumToMatch < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :player_num, :integer, null: false, default: 0
  end
end
