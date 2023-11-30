class AddPlayTypeToMatchGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :match_groups, :play_type, :integer
  end
end
