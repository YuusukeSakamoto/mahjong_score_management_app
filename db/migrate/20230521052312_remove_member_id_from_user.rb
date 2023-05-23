class RemoveMemberIdFromUser < ActiveRecord::Migration[6.1]
  
  def change
    remove_column :users, :member_id, :integer
    remove_column :users, :admin_flag, :integer

  end
end
