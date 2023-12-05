class RenameUma1ToUmaOne < ActiveRecord::Migration[6.1]
  def change
    rename_column :rules, :uma_1, :uma_one
    rename_column :rules, :uma_2, :uma_two
    rename_column :rules, :uma_3, :uma_three
    rename_column :rules, :uma_4, :uma_four
  end
end
