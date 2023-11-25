class MatchGroupsController < ApplicationController
  before_action :set_match_group, only: [:show, :destroy]
  before_action :authenticate_user!

  # 記録したor記録された成績表一覧を表示する / ログインユーザーのみ照会可能
  def index
    match_ids = Result.match_ids(current_player.id)
    mg_ids = Match.where(id: match_ids).distinct.pluck(:match_group_id)
    @match_groups = MatchGroup.where(id: mg_ids).desc
  end
  
  def show
    if params[:fix] == 'true' # 対局成績を確定ボタンから遷移した場合
      end_record
      flash.now[:notice] = "記録を終了しました"
    end
  end
  
  def destroy
    redirect_to root_path, alert: "削除権限がありません" and return if @match_group.matches.first.player_id != current_player.id
    if @match_group
      @match_group.destroy
      redirect_to match_groups_path, notice: "対局成績表を削除しました"
    else
      redirect_to root_path, alert: "削除できませんでした" and return
    end
    
  end
  
  private
  
    def set_match_group
      @match_group = MatchGroup.find_by(id: params[:id])
    end

end