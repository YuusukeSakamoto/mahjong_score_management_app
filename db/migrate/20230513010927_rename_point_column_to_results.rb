class RenamePointColumnToResults < ActiveRecord::Migration[6.1]
  def change
    rename_column :results, :pointeger, :point
  end
end
