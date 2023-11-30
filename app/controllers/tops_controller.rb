class TopsController < ApplicationController
  
  def show
    if user_signed_in?
      if recording?
        @match_group = set_match_group_by_session
        @rule = Rule.find_by(id: @match_group.rule_id)
        @create_day = @match_group.matches.last.created_at.to_date.to_s(:yeardate)
      end
      @player = Player.find_by(user_id: current_user.id)
    end
  end
  
end