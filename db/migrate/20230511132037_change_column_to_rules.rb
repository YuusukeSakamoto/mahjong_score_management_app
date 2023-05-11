class ChangeColumnToRules < ActiveRecord::Migration[6.1]
  def change
    change_column_null :rules, :chip_rate, true
    change_column_null :rules, :description, true
  end
end
