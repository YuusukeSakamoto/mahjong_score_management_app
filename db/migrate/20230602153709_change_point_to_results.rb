class ChangePointToResults < ActiveRecord::Migration[6.1]
  def change
    change_column :results, :point, :float
  end
end
