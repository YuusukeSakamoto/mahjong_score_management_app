class MatchGroupsController < ApplicationController
  before_action :set_match_group, only: [:show, :destroy]
  before_action :authenticate_user!

  # 記録したor記録された成績表一覧を表示する
  def index
    match_ids = Result.match_ids(current_player.id)
    mg_ids = Match.where(id: match_ids).distinct.pluck(:match_group_id)
    @match_groups = MatchGroup.includes(:matches).where(id: mg_ids, play_type: 4).desc #デフォルトは四麻
    @first_match_results_p_ids = @match_groups.map { |mg| mg.matches.first.results.pluck(:player_id) }
    @first_match_player_ids = @match_groups.map { |mg| mg.matches.first.player_id }
  end

  def show
    # match_groupのmatchにcurrent_playerが含まれていない場合、アクセス不可
    redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @match_group.players.include?(current_player)
    if params[:fix] == 'true' # 対局成績を確定ボタンから遷移した場合
      end_record
      flash.now[:notice] = FlashMessages::END_RECORD
    end
    @rule = Rule.find_by(id: @match_group.rule_id)
    @create_day = @match_group.matches.last.created_at.to_date.to_s(:yeardate)
  end

  def destroy
    redirect_to root_path, alert: FlashMessages::DESTROY_DENIED and return unless @match_group.created_by?(current_player)
    if @match_group
      @match_group.destroy
      redirect_to match_groups_path, notice: FlashMessages::DESTROY_MATCH_GROUP
    else
      redirect_to root_path, alert: FlashMessages::CANNOT_DESTROY and return
    end

  end

  private

    def set_match_group
      @match_group = MatchGroup.find_by(id: params[:id])
      redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @match_group
    end

end