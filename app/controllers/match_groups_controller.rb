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
    if params[:tk] && params[:resource_type]
      share_token_valid? # トークンが有効か判定
      set_league_link if @match_group.league_id.present?
      set_share_link if user_signed_in?
    else
      redirect_to(user_session_path,
                  alert: FlashMessages::UNAUTHENTICATED) && return unless current_user #ログインユーザーがアクセスしているか判定
      unless @match_group.players.include?(current_player) # match_groupにcurrent_playerが含まれていない場合、アクセス不可
        redirect_to(root_path,
                    alert: FlashMessages::ACCESS_DENIED) && return
      end
      set_share_link
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

  #===================================
  # 共有リンク関連
  #===================================
  # 共有トークンが有効か判定する
  def share_token_valid?
    @share_token = ShareLink.find_by(token: params[:tk], resource_type: params[:resource_type])

    unless @share_token
      redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
      return false
    end

    case params[:resource_type]
    when 'MatchGroup'
      unless @match_group == MatchGroup.find_by(id: @share_token.resource_id)
        redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
        return false
      end
    when 'League'
      league = League.find_by(id: @share_token.resource_id)
      unless league.match_groups.include?(@match_group)
        redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
        return false
      end
    end

    true
  end

  # share_tokenが有効かつmatchgroupにリーグ情報がある場合、リーグ情報を取得する
  def set_league_link
    league = League.find_by(id: @match_group.league_id)
    @league_link = ShareLink.find_by(resource_id: league.id, resource_type: 'League')
    redirect_to(root_path, alert: FlashMessages::ERROR) && return unless @league_link
  end

  # 共有リンクを発行する
  def set_share_link
    @share_link = ShareLink.find_or_create(current_user, @match_group.id, 'MatchGroup')
    @share_link.generate_reference_url('MatchGroup')
  end
end
