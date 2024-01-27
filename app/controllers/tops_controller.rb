# frozen_string_literal: true

class TopsController < ApplicationController
  def show
    return unless user_signed_in?

    if recording?
      @match_group = set_match_group_by_session
      @matches = @match_group.matches
      @rule = Rule.find_by(id: @match_group.rule_id)
      @last_match_day = @match_group.last_match_day
    end
    @player = Player.find_by(user_id: current_user.id)
  end
end
