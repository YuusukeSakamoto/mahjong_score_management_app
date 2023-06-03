class RenameMatchDayColumnToMatches < ActiveRecord::Migration[6.1]
  def change
    rename_column :matches, :match_day, :match_on
  end
end
