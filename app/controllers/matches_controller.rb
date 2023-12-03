class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  attr_accessor :mg

  def index
    match_ids = current_player.match_ids_for_play_type(4) #デフォルトは四麻
    @matches = Match.where(id: match_ids).desc
  end

  def new
    if params[:league].present?
      @league = League.find_by(id: params[:league])
      redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @league
      set_alert_redirect_root(FlashMessages::CANNOT_RECORD_LEAGUE) unless current_player.id == League.find_by(id: params[:league]).player_id # リーグ主催者でなければ成績登録不可
    end
    # 他の成績を記録中の場合、新規登録不可
    set_alert_redirect_root(FlashMessages::RECORDING_NOW) if session[:mg].present? && params[:league].present? && (session[:league] != params[:league])
    # プレイヤーが選択されていない場合、新規登録不可
    set_alert_redirect_root(FlashMessages::PLAYER_NOT_SELECTED) if session[:players].nil? && params[:league].nil?

    @players = session[:players]
    set_league_data if params[:league].present?
    set_league if session[:league].present?

    initialize_match
  end

  def show
    # matchにcurrent_playerが含まれていない場合、アクセス不可
    redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @match.results.pluck(:player_id).include?(current_player.id)
    @match_group = MatchGroup.find_by(id: @match.match_group_id)
    @rule = Rule.find_by(id: @match_group.rule_id)
    @create_day = @match_group.matches.last.created_at.to_date.to_s(:yeardate)
    session[:previous_url] = request.referer unless request.referer.include?(edit_match_path)
  end

  def create
    @match = Match.new(match_params)
    redirect_to root_path, alert: FlashMessages::FAIED_TO_CREATE_MATCH and return unless current_player == @match.player
    if ie_uniq?(@match) && @match.save
      create_match_group unless recording?
      @match.update(match_group_id: session[:mg])
      redirect_to match_path(@match), notice: FlashMessages::CREATE_MATCH
    else
      @players = session[:players]
      render :new
    end
  end

  def edit
    redirect_to root_path, alert: FlashMessages::EDIT_DENIED and return unless current_player == @match.player
    set_player_league
    set_gon('edit')
  end

  def update
    redirect_to root_path, alert: FlashMessages::UPDATE_DENIED and return unless current_player == @match.player
    if ie_uniq?(@match) && @match.update(match_params)
      redirect_to match_path(@match), notice: FlashMessages::UPDATE_MATCH
    else
      set_player_league
      set_gon('update')
      render :edit
    end
  end

  def destroy
    redirect_to root_path, alert: FlashMessages::DESTROY_DENIED and return unless current_player == @match.player
    if @match.destroy
      set_redirect_to(@match)
    else
      redirect_to root_path, alert: FlashMessages::CANNOT_DESTROY and return
    end
  end

  # jsに渡す変数をセットする
  def set_gon(action)
    if action == 'new'
      gon.is_recording = recording?
      gon.is_league_recording = league_recording?
    elsif action == 'edit' || action == 'update'
      gon.is_edit = true # edit・updateの場合、無条件でルールは更新できないようにする
    end
  end

  private

    def set_match
      @match = Match.find_by(id: params[:id])
      redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @match
    end

    # セッションからleagueをセット
    def set_league
      @league = League.find(session[:league])
    end

    # リーグに関するデータをセッション等にセットする
    def set_league_data
      session[:league] = params[:league]
      session[:rule] = @league.rule.id
      @players = @league.league_players.map {|l_player| l_player.player }
      session[:players] = @players
    end

    # match初回登録時、match_groupを登録しセッションへmatch_groupとruleを格納する
    def create_match_group
      @mg = MatchGroup.create(rule_id: params[:match][:rule_id], league_id: session[:league], play_type: session_players_num)
      create_chip_results if @mg.rule.is_chip
      session[:mg] = @mg.id
      session[:rule] = params[:match][:rule_id] # ２回目以降の成績登録時のデフォルトルールとして使用するためrule_idをセットする
    end

    # チップ有ルールの場合、仮で0枚登録する
    def create_chip_results
      session[:players].each do |player|
        @mg.chip_results.create(player_id: player["id"], point: 0, number: 0, is_temporary: 1)
      end
    end

    def match_params
      params.require(:match).
            permit(:rule_id, :player_id, :match_on, :memo, :play_type, :league_id,
                    results_attributes: [:id, :score, :point, :ie, :player_id, :rank])
    end

    # 入力された家に重複がないか
    def ie_uniq?(match)
      ie_ary = params[:match][:results_attributes].values.map { |result| result[:ie].to_i }
      if ie_ary.uniq.length == ie_ary.length
        true
      else
        match.errors.add(:ie, "が重複しています")
        false
      end
    end

    def set_player_league
      player_ids = @match.results.pluck(:player_id)
      @players = Player.where(id: player_ids)
      @league = League.find_by(id: @match.league_id)
    end

    # match.newとセッション/gonの設定
    def initialize_match
      @match = Match.new
      @match.play_type = @players.count
      session_players_num.times { @match.results.build }
      set_gon('new')
    end

    # ***************** destroyアクション ************************ # 

    # リダイレクト先を判定する
    def set_redirect_to(match)
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
        redirect_with_notice(session[:previous_url])
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