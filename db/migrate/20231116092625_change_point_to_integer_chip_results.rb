class ChangePointToIntegerChipResults < ActiveRecord::Migration[6.1]
  def change
    change_column :chip_results, :point, :integer
  end
end
