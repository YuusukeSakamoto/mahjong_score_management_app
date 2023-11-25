class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  
  attr_accessor :mg

  def index
    if params[:p_id].present?
      @player = Player.find_by(id: params[:p_id])
      if @player
        match_ids = Result.match_ids(params[:p_id])
        @matches = Match.where(id: match_ids).desc
      else
        set_alert_redirect_root("指定されたプレイヤーは存在しません")
      end
    else
      set_alert_redirect_root("プレイヤーIDが指定されていません")
    end
  end  
  
  def new
    set_alert_redirect_root("他の成績を記録中です") if session[:mg].present? && params[:league].present? && (session[:league] != params[:league])
    set_alert_redirect_root("プレイヤーが選択されていません") if session[:players].nil? && params[:league].nil?
  
    @players = session[:players]
    set_league_data if params[:league].present?
    set_league if session[:league].present?
  
    initialize_match
  end
  
  def show
    @match_group = MatchGroup.find_by(id: @match.match_group_id)
    session[:pre_path] = request.referer unless request.referer.include?(edit_match_path)
  end
  
  def create
    @match = Match.new(match_params)
    if ie_uniq?(@match) && @match.save
      create_match_group unless recording?
      @match.update(match_group_id: session[:mg])
      redirect_to match_path(@match), notice: "対局成績を登録しました"
    else
      @players = session[:players]
      render :new
    end
  end
  
  def edit
    set_player_league
    set_gon('edit')
  end
  
  def update
    if ie_uniq?(@match) && @match.update(match_params)
      redirect_to match_path(@match), notice: "対局成績を更新しました"
    else
      set_player_league
      set_gon('update')
      render :edit
    end
  end
  
  def destroy
    unless valid_match_for_current_player?(@match)
      redirect_to root_path, alert: "指定の対局成績が存在しません" and return
    end
  
    if @match.destroy
      set_redirect_to(@match)
    else
      redirect_to root_path, alert: "削除できませんでした" and return
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
    end
    
    # セッションからleagueをセット
    def set_league
      @league = League.find(session[:league])
    end
    
    # リーグに関するデータをセッション等にセットする
    def set_league_data
      @league = League.find(params[:league])
      session[:league] = params[:league]
      session[:rule] = @league.rule.id
      @players = @league.league_players.map {|l_player| l_player.player }
      session[:players] = @players
    end
    
    # match初回登録時、match_groupを登録しセッションへmatch_groupとruleを格納する
    def create_match_group
      @mg = MatchGroup.create(rule_id: params[:match][:rule_id], league_id: session[:league])
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
    
    def valid_match_for_current_player?(match)
      match && match.player_id == current_player.id
    end
    
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
        redirect_with_notice(session[:pre_path])
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
      redirect_to path, notice: "対局成績を削除しました"
    end
    
    def redirect_back_with_notice
      redirect_back(fallback_location: root_path, notice: "対局成績を削除しました")
    end

end
