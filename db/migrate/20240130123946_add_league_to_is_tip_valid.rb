class AddLeagueToIsTipValid < ActiveRecord::Migration[6.1]
  def change
    add_column :leagues, :is_tip_valid, :boolean, default: false, null: false
  end
end
