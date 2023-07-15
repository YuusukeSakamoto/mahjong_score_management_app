class MatchGroupsController < ApplicationController
  before_action :authenticate_user!

  # 記録したor記録された成績表一覧を表示する / ログインユーザーのみ照会可能
  def index
    match_ids = Result.match_ids(current_player.id)
    mg_ids = Match.where(id: match_ids).distinct.pluck(:match_group_id)
    @match_groups = MatchGroup.where(id: mg_ids).desc
  end
  
  def show
    @match_group = MatchGroup.find(params[:id])
    if params[:fix] == 'true' # 対局成績を確定ボタンから遷移した場合
      end_record
    end
  end

end
