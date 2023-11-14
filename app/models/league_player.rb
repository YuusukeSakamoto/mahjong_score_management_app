class LeaguePlayer < ApplicationRecord
  belongs_to :league
  belongs_to :player
  
  # validates :, presence: true, numericality: { in: 3..4 }
  
  def self.create(players, league_id)
    LeaguePlayer.transaction do
      players.each do |player|
        LeaguePlayer.create!(player_id: player.id, league_id: league_id)
      end
    end      
      return true
    rescue => e
      return false
  end
  
end
