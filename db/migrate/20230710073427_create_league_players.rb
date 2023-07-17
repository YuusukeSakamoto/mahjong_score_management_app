class CreateLeaguePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :league_players do |t|
      t.references :league, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
