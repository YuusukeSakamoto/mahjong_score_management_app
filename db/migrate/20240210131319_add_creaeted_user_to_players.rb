class AddCreaetedUserToPlayers < ActiveRecord::Migration[6.1]
  def change
    add_column :players, :created_user, :integer
  end
end
