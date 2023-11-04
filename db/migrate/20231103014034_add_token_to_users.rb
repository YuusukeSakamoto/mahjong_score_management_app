class AddTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :player_select_token, :string
    add_index :users, :player_select_token, unique: true
    add_column :users, :player_select_token_created_at, :datetime
    add_column :users, :token_issued_user, :integer
  end
end
