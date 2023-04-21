class AddNameAdiminFlagToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string, null:false
    add_column :users, :admin_flag, :int, defalut:0
  end
end
