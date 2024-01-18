# frozen_string_literal: true

class MatchGroupsController < ApplicationController
  before_action :set_match_group, only: %i[show destroy]
  before_action :authenticate_user!, except: [:show]

  # 記録したor記録された成績表一覧を表示する
  def index
    match_ids = Result.match_ids(current_player.id)
    mg_ids = Match.where(id: match_ids).distinct.pluck(:match_group_id)
    @match_groups = MatchGroup.includes(:matches).where(id: mg_ids, play_type: 4).desc # デフォルトは四麻
    @first_match_results_p_ids = @match_groups.map { |mg| mg.matches.first.results.pluck(:player_id) }
    @first_match_recorded_player_ids = @match_groups.map { |mg| mg.matches.first.player_id }
  end

  def show
    if params[:tk] && !user_signed_in? #トーク有かつログオフ状態の場合
      share_link_valid?
    else
      redirect_to(user_session_path,
                  alert: FlashMessages::UNAUTHENTICATED) && return unless current_user #ログインユーザーがアクセスしているか判定
      unless @match_group.players.include?(current_player) # match_groupにcurrent_playerが含まれていない場合、アクセス不可
        redirect_to(root_path,
                    alert: FlashMessages::ACCESS_DENIED) && return
      end
      @share_link = ShareLink.find_by(user_id: current_user.id, resource_id: params[:id], resource_type: 1)
      @share_link.generate_reference_url
    end

    if params[:fix] == 'true' # 対局成績を確定ボタンから遷移した場合
      end_record
      flash.now[:notice] = FlashMessages::END_RECORD
    end
    @rule = Rule.find_by(id: @match_group.rule_id)
    @create_day = @match_group.matches.last.created_at.to_date.to_s(:yeardate)
    @matches = @match_group.matches
  end

  def destroy
    unless @match_group.created_by?(current_player)
      redirect_to(root_path,
                  alert: FlashMessages::DESTROY_DENIED) && return
    end

    redirect_to(root_path, alert: FlashMessages::CANNOT_DESTROY) && return unless @match_group

    @match_group.destroy
    redirect_to match_groups_path, notice: FlashMessages::DESTROY_MATCH_GROUP
  end

  private

  # showアクション用の認証ユーザー検証
  def authenticate_user_for_show
    redirect_to(user_session_path, alert: FlashMessages::UNAUTHENTICATED) && return unless current_user
  end

  def set_match_group
    @match_group = MatchGroup.find_by(id: params[:id])
    redirect_to(root_path, alert: FlashMessages::ACCESS_DENIED) && return unless @match_group
  end

  # トークンが有効か判定する
  def share_link_valid?
    @share_link = ShareLink.find_by(token: params[:tk], resource_id: params[:id])
    return true if share_link_valid_for_resource?(params[:id])
    redirect_to(root_path, alert: FlashMessages::INVALID_LINK) && return
  end

  # match_groupの適切なtokenか判定
  def share_link_valid_for_resource?(resource_id)
    @share_link && @share_link.match_group? && @share_link.resource_id.to_s == resource_id
  end

end
