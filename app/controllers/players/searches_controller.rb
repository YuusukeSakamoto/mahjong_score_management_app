# frozen_string_literal: true

class Players::SearchesController < ApplicationController
  def index
    @player = Player.find(params[:id])

    respond_to do |format|
      format.html { redirect_to :root }
      format.json { render json: @player } # json: オブジェクトで指定すること
    end
  end
end
