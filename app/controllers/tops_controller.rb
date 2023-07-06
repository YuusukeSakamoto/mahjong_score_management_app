class TopsController < ApplicationController
  
  def show
    if user_signed_in?
      @match_group = set_session_match_group if recording?
      
      @sanyon_matches = {}
      @sanyon_match_ids = {}
      
      match_ids = Result.match_ids(current_player.id)
      @sanyon_matches[3] = Match.sanma(match_ids).desc.first(5)
      @sanyon_matches[4] = Match.yonma(match_ids).desc.first(5)
      @player = Player.find_by(user_id: current_user.id)
      @sanyon_match_ids[3] = Match.sanma(match_ids) #三麻のmatch_idを配列で格納
      @sanyon_match_ids[4] = Match.yonma(match_ids) #四麻のmatch_idを配列で格納
    end
  end
end
