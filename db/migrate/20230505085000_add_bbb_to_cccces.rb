class AddBbbToCccces < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :member_count, :int, null: false
  end
end
