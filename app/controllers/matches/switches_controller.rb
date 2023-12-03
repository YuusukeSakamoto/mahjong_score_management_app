# app/controllers/matches/switches_controller.rb
module Matches
  class SwitchesController < ApplicationController
    def index
      play_type = params[:play_type] || 4 # デフォルトは四麻
      match_ids = current_player.match_ids_for_play_type(play_type) #デフォルトは四麻
      @matches = Match.where(id: match_ids).desc
      respond_to do |format|
        format.js
      end
    end
  end
end
