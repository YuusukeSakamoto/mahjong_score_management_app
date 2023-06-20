class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  
  def index
    match_ids = Result.where(player_id: params[:p_id]).select(:match_id).pluck(:match_id)
    @matches = Match.where(id: match_ids).desc
  end  
  
  def new
    @match = Match.new
    session_player_num.times { @match.results.build }
  end
  
  def show
  end
  
  def create
    @match = Match.new(match_params)
    if ie_uniq?(@match) && @match.save
      redirect_to match_path(@match), notice: "対局成績を登録しました"
    else
      render :new
    end
  end
  
  def edit; end
  
  def update
    if ie_uniq?(@match) && @match.update(match_params)
      redirect_to match_path(@match), notice: "対局成績を更新しました"
    else
      render :edit
    end
  end
  
  def destroy
    @match.destroy
    redirect_to matches_path , notice: "対局成績を削除しました"
  end
  
  private
    
    def set_match
      @match = Match.find(params[:id])
    end
    
    def match_params
      params.require(:match).
        permit(:rule_id, :player_id, :match_on, :memo, :player_num, results_attributes: [:id, :score, :point, :ie, :player_id, :rank])
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
