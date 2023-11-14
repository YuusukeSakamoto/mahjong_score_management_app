class TopsController < ApplicationController
  
  def show
    if user_signed_in?
      @match_group = set_session_match_group if recording?
      @player = Player.find_by(user_id: current_user.id)
    end
  end
  
end