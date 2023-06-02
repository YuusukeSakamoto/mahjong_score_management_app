class AddNotNullIsChipToRule < ActiveRecord::Migration[6.1]
  def change
    change_column :rules, :is_chip, :boolean,  default: false, null: false
  end
end
