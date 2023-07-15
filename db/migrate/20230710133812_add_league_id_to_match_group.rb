class AddLeagueIdToMatchGroup < ActiveRecord::Migration[6.1]
  def change
    add_reference :match_groups, :league, foreign_key: true
  end
end
