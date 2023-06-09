class TopsController < ApplicationController
  
  def show
    if user_signed_in?
      match_ids = Result.where(player_id: current_user.player.id).select(:match_id).pluck(:match_id)
      @matches = Match.where(id: match_ids).order(match_on: :DESC).first(5)
    end
  end
end
