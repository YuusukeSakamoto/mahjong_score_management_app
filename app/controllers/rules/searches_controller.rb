class Rules::SearchesController < ApplicationController
  def index
    @rule = Rule.find(params[:id])

    respond_to do |format| 
      format.html { redirect_to :root } 
      format.json { render json: @rule  } #json: オブジェクト　で指定すること
    end
    
  end
end
