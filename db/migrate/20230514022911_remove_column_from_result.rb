class RemoveColumnFromResult < ActiveRecord::Migration[6.1]
  def change
    remove_column :results, :rule_id, :integer
    remove_column :results, :match_time, :date
    remove_column :results, :recorded_player_id, :integer
    remove_column :results, :memo, :string
  end
end
