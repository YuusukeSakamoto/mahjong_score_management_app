class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  
  def index
    match_id = Result.all.where(player_id: current_user.player.id).select(:match_id).pluck(:match_id)
    @matches = Match.all.where(id: match_id)
  end  
  
  def new
    @match = Match.new
    4.times { @match.results.build }
  end
  
  def show
  end
  
  def create
    @match = Match.new(match_params)
    if @match.save && ie_uniq?(@match)
      redirect_to match_path(@match), flash: {notice: "対局成績を登録しました"}
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @match.update(match_params) && ie_uniq?(@match)
      redirect_to match_path(@match), flash: {notice: "対局成績を更新しました"}
    else
      render :edit
    end
  end
  
  def destroy
    @match.destroy
    redirect_to matches_path , flash: {notice: "対局成績を削除しました"}
  end
  
  private
    
    def set_match
      @match = Match.find(params[:id])
    end
    
    def match_params
      params.require(:match).
        permit(:rule_id, :player_id, :match_at, :memo, results_attributes: [:id, :score, :point, :ie, :player_id, :rank])
    end
    
    # 入力された家に重複がないか
    def ie_uniq?(match)
      ie_ary = match.results.map(&:ie)
      if ie_ary.uniq.length == ie_ary.length
        true
      else
        match.errors.add(:ie, "が重複しています")
        false
      end
    end

end
