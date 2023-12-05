# frozen_string_literal: true

class Rules::SearchesController < ApplicationController
  def index
    @rule = Rule.find(params[:id])

    respond_to do |format|
      format.html { redirect_to :root }
      format.json { render json: @rule } # json: オブジェクト　で指定すること
    end
  end

  def show
    play_type = params[:play_type]
    # play_type に基づいてルールをフィルタリング
    rules = current_player.rule_list(play_type)
    render json: rules
  end
end
