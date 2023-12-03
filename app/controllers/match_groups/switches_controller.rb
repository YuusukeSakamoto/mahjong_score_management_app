# app/controllers/matche_groups/switches_controller.rb
module MatchGroups
  class SwitchesController < ApplicationController
    def index
      match_ids = Result.match_ids(current_player.id)
      mg_ids = Match.where(id: match_ids).distinct.pluck(:match_group_id)
      play_type = params[:play_type] || 4 # デフォルトは四麻
      @match_groups = MatchGroup.includes(:matches).where(id: mg_ids, play_type: play_type).desc
      @first_match_results_p_ids = @match_groups.map { |mg| mg.matches.first.results.pluck(:player_id) }
      @first_match_player_ids = @match_groups.map { |mg| mg.matches.first.player_id }
      respond_to do |format|
        format.js
      end
    end
  end
end
