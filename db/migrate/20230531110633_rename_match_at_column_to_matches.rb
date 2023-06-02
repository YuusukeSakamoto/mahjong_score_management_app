class RenameMatchAtColumnToMatches < ActiveRecord::Migration[6.1]
  def change
    rename_column :matches, :match_at, :match_day
  end
end
