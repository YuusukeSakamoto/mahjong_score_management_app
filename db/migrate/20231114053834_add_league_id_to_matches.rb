class AddLeagueIdToMatches < ActiveRecord::Migration[6.1]
  def change
    add_reference :matches, :league, foreign_key: true
    add_reference :match_groups, :rule, foreign_key: true, null: false
    add_reference :match_groups, :league, foreign_key: true

  end
end
