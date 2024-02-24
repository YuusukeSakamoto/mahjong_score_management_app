# frozen_string_literal: true

class MatchesController < ApplicationController
  before_action :set_match, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: [:show]

  attr_accessor :mg

  def index
    match_ids = current_player.match_ids_for_play_type(4) # デフォルトは四麻
    @matches = Match.includes(:results).where(id: match_ids).desc
    gon_setter('index')
  end

  def new
    if params[:league].present?
      @league = League.find_by(id: params[:league])
      redirect_to(root_path, alert: FlashMessages::ACCESS_DENIED) && return unless @league

      unless league_record_permit?
        alert_redirect_root(FlashMessages::CANNOT_RECORD_LEAGUE)
      end
      # リーグ成績を記録中、他のリーグ成績の登録不可
      if session[:mg].present? && (session[:league] != params[:league])
        alert_redirect_root(FlashMessages::RECORDING_NOW)
      end
      set_league_data # リーグ戦の場合、セッションにリーグ情報を格納する
    end
    @players = session[:players]
    # プレイヤーが選択されていない場合、新規登録不可
    alert_redirect_root(alert: FlashMessages::PLAYER_NOT_SELECTED) && return unless @players

    initialize_match
  end

  def show
    if params[:tk] && params[:resource_type]
      @share_token = validate_share_token(params[:tk],
                                          params[:resource_type],
                                          'matches_controller',
                                          @match) # トークンが有効か判定
    else
      #ログアウトユーザーはアクセス拒否
      unless current_user
        redirect_to(user_session_path,
                    alert: FlashMessages::UNAUTHENTICATED) && return
      end
      # matchにcurrent_playerが含まれていない場合、アクセス不可
      unless @match.results.pluck(:player_id).include?(current_player.id) || @match_group.created_by?(current_player)
        redirect_to(root_path,
                    alert: FlashMessages::ACCESS_DENIED) && return
      end
      #トークン無かつログイン状態の場合、match_groupに紐づく共有リンクが未作成であれば作成する
      @share_link = ShareLink.find_or_create(current_user, @match_group.id, 'MatchGroup')
      @share_link.generate_reference_url('MatchGroup')
    end

    @matches = @match_group.matches
    @rule = Rule.find_by(id: @match_group.rule_id)
    @last_match_day = @match_group.last_match_day
    if request.referer.present?
      unless request.referer.include?(edit_match_path)
        session[:previous_url] = request.referer
      end
    end
    gon_setter('show')
  end

  def create
    @match = Match.new(match_params)
    redirect_to(root_path, alert: FlashMessages::FAIED_TO_CREATE_MATCH) && return unless current_player == @match.player

    if ie_uniq?(@match) && @match.save
      create_match_group unless recording?
      @match.update(match_group_id: session[:mg])
      redirect_to match_path(@match), notice: FlashMessages::CREATE_MATCH
    else
      @players = session[:players]
      score_in_hundred
      render :new
    end
  end

  def edit
    score_in_hundred
    redirect_to(root_path, alert: FlashMessages::EDIT_DENIED) && return unless current_player == @match.player

    set_player_league
    gon_setter('edit')
  end

  def update
    redirect_to(root_path, alert: FlashMessages::UPDATE_DENIED) && return unless current_player == @match.player

    if ie_uniq?(@match) && @match.update(match_params)
      redirect_to match_path(@match), notice: FlashMessages::UPDATE_MATCH
    else
      set_player_league
      gon_setter('update')
      score_in_hundred
      render :edit
    end
  end

  def destroy
    redirect_to(root_path, alert: FlashMessages::DESTROY_DENIED) && return unless current_player == @match.player
    redirect_to(root_path, alert: FlashMessages::CANNOT_DESTROY) && return unless @match.destroy
    get_redirect_to(@match)
  end

  # jsに渡す変数をセットする
  def gon_setter(action)
    if %w[new edit update].include?(action)
      if recording? || league_recording? # 記録中の場合、ルールは更新できないようにする
        gon.is_fixed_rule = true
      else
        gon.is_fixed_rule = false
      end
    else
      gon.is_fixed_rule = false
    end
  end

  private

  def set_match
    @match = Match.find_by(id: params[:id])
    redirect_to(root_path, alert: FlashMessages::ACCESS_DENIED) && return unless @match
    set_match_group
  end

  def set_match_group
    @match_group = MatchGroup.find_by(id: @match.match_group_id)
    redirect_to(root_path, alert: FlashMessages::ACCESS_DENIED) && return unless @match_group
  end

  # リーグに関するデータをセッション等にセットする
  def set_league_data
    @league = League.find(params[:league])
    session[:league] = params[:league]
    session[:rule] = @league.rule.id
    @players = @league.league_players.map(&:player)
    session[:players] = @players
  end

  # match初回登録時、match_groupを登録しセッションへmatch_groupとruleを格納する
  def create_match_group
    @mg = MatchGroup.create(rule_id: params[:match][:rule_id], league_id: session[:league],
                            play_type: session_players_num)
    create_chip_results if @mg.rule.is_chip
    session[:mg] = @mg.id
    session[:rule] = params[:match][:rule_id] # ２回目以降の成績登録時のデフォルトルールとして使用するためrule_idをセットする
  end

  # チップ有ルールの場合、仮で0枚登録する
  def create_chip_results
    session[:players].each do |player|
      @mg.chip_results.create(player_id: player['id'], point: 0, number: 0, is_temporary: 1)
    end
  end

  def match_params
    score_multiplied_by_hundred
    params.require(:match)
          .permit(:rule_id, :player_id, :match_on, :memo, :play_type, :league_id,
                  results_attributes: %i[id score point ie player_id rank])
  end

  # scoreは十の位以下なしでフォームから送信されるため、×100する
  def score_multiplied_by_hundred
    params[:match][:results_attributes].each do |result|
      result[1][:score] = result[1][:score].to_i * 100
    end
  end

  # 編集時表示するscoreは十の位以下なしにするため、÷100する
  def score_in_hundred
    @match.results.each do |result|
      result.score = result.score / 100
    end
  end


  # 入力された家に重複がないか
  def ie_uniq?(match)
    ie_ary = params[:match][:results_attributes].values.map { |result| result[:ie].to_i }
    if ie_ary.uniq.length == ie_ary.length
      true
    else
      match.errors.add(:ie, 'が重複しています')
      false
    end
  end

  def set_player_league
    player_ids = @match.results.pluck(:player_id)
    @players = Player.find(player_ids)
    @league = League.find_by(id: @match.league_id)
  end

  # match.newとセッション/gonの設定
  def initialize_match
    @match = Match.new
    @match.play_type = @players.count
    session_players_num.times { @match.results.build }
    gon_setter('new')
  end

  # リーグ戦において記録可能プレイヤーか真偽値を返す
  def league_record_permit?
    (current_player.id == League.find_by(id: params[:league]).player_id) ||
      LeaguePlayer.exists?(player_id: current_player.id, league_id: params[:league])
  end

  # ***************** destroyアクション ************************ #
  # リダイレクト先を判定する
  def get_redirect_to(match)
    mg = MatchGroup.find_by(id: match.match_group_id)
    match_count = mg.matches.count

    if recording?
      recording_flow(mg, match_count)
    else
      non_recording_flow(mg, match_count)
    end
  end

  # 記録中の場合
  def recording_flow(mg, match_count)
    if match_count.zero?
      mg.destroy
      end_record
      redirect_with_notice(root_path)
    else
      redirect_with_notice(match_path(mg.matches.last.id))
    end
  end

  # 記録中ではない場合
  def non_recording_flow(mg, match_count)
    case params[:btn]
    when 'match'
      if match_count.zero?
        mg.destroy
        redirect_with_notice(match_groups_path)
      else
        redirect_with_notice(session[:previous_url])
      end
    when 'mg'
      handle_match_group_flow(mg, match_count)
    end
  end

  # 成績表の削除ボタンから削除された場合
  def handle_match_group_flow(mg, match_count)
    if match_count.zero?
      mg.destroy
      redirect_with_notice(match_groups_path)
    else
      redirect_back_with_notice
    end
  end

  def redirect_with_notice(path)
    session[:previous_url] = nil if session[:previous_url]
    redirect_to path, notice: FlashMessages::DESTROY_MATCH
  end

  def redirect_back_with_notice
    redirect_back(fallback_location: root_path, notice: FlashMessages::DESTROY_MATCH)
  end
end
