# frozen_string_literal: true

# app/controllers/matches/switches_controller.rb
module Matches
  class SwitchesController < ApplicationController
    # matchコントローラのindexアクションと同じ処理を記載しないとエラーになるため注意
    def index
      play_type = params[:play_type] || 4 # デフォルトは四麻
      match_ids = current_player.match_ids_for_play_type(play_type)
      @matches = Match.includes(:results).where(id: match_ids).desc
      respond_to(&:js)
    end
  end
end
