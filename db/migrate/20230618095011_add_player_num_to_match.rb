class AddPlayerNumToMatch < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :play_type, :integer, null: false
  end
end
