# frozen_string_literal: true

class LeaguePlayer < ApplicationRecord
  belongs_to :league
  belongs_to :player

  def self.create(players, league_id)
    LeaguePlayer.transaction do
      players.each do |player|
        LeaguePlayer.create!(player_id: player.id, league_id: league_id)
      end
    end
    true
  rescue StandardError => e
    Rails.logger.error e
  end
end
