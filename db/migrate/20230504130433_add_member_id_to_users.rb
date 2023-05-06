class AddMemberIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :member_id, :int ,unique: true, null: false 
  end
end
