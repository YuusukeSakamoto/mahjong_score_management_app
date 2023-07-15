class ChangeDataChipExisitanceFlagToRule < ActiveRecord::Migration[6.1]
  def change
    change_column :rules, :is_chip, :boolean, default: false, null: false
    rename_column :rules, :is_chip, :is_chip
  end
end
