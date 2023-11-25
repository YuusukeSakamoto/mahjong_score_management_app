class TopsController < ApplicationController
  
  def show
    if user_signed_in?
      @match_group = set_match_group_by_session if recording?
      @player = Player.find_by(user_id: current_user.id)
    end
  end
  
end