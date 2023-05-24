class MatchesController < ApplicationController
  
  def new
    @match = Match.new
    4.times { @match.results.build }
  end
  
  def show
    @match = Match.find(params[:id])
  end
  
  def create
    @match = Match.new(match_params)
    # byebug
    # scores.transpose[1].include?(nil)
    is_filled = true
    @match.results.each do |r|
      is_filled = false if r.score == nil
    end
    Match.set_rank(@match) if is_filled #scoreをもとに順位を設定する
    if @match.save
      redirect_to '/', flash: {notice: "対局成績を登録しました"}
    else
      # ★ 不要
      # @match = Match.new
      # 4.times { @match.results.build }
      # flash.now[:alert] = "対局成績登録に失敗しました。再度入力してください。"
      render :new
    end
  end
  
  
  private
    
    def match_params
      params.require(:match).
        permit(:rule_id, :player_id, :rank, :match_day, :memo, results_attributes: [:score, :point, :ie, :player_id])
    end

end
