# app/controllers/matches/switches_controller.rb
module Matches
  class SwitchesController < ApplicationController
    def index
      play_type = params[:play_type] || 4 # デフォルトは四麻
      @matches = Match.where(player_id: current_player.id, play_type: play_type).desc
      respond_to do |format|
        format.js
      end
    end
  end
end
