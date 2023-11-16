class AddLeagueIdToMatches < ActiveRecord::Migration[6.1]
  def change
    add_reference :matches, :league, foreign_key: true
  end
end
