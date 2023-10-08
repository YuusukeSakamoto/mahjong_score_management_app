class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  
  attr_accessor :mg
  
  def index
    @player = Player.find(params[:p_id])
    match_ids = Result.match_ids(params[:p_id])
    @matches = Match.where(id: match_ids).desc
  end  
  
  def new
    if session[:players].nil? && params[:league].nil?
      redirect_to root_path, flash: {alert: 'プレイヤーが選択されていません'} and return 
    end
    @players = session[:players]
    set_league_data if params[:league].present? #リーグ対局記録ボタンから遷移したきた場合
    @match = Match.new
    @match.play_type = @players.count
    session_players_num.times { @match.results.build }
    gon.is_recording = recording?
    gon.is_league_recording = league_recording?
  end
  
  def show
    @match_group = set_session_match_group if recording?
  end
  
  def create
    create_match_group until recording?
    @match = Match.new(match_params)
    if ie_uniq?(@match) && @match.save
      redirect_to match_path(@match), notice: "対局成績を登録しました"
    else
      render :new
    end
  end
  
  def edit
    player_ids = @match.results.pluck(:player_id)
    @players = Player.where(id: player_ids)
  end
  
  def update
    if ie_uniq?(@match) && @match.update(match_params)
      redirect_to match_path(@match), notice: "対局成績を更新しました"
    else
      render :edit
    end
  end
  
  def destroy
    @match.destroy
    redirect_back fallback_location: root_path , notice: "対局成績を削除しました"
  end
  
  private
    
    def set_match
      @match = Match.find(params[:id])
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
            permit(:rule_id, :player_id, :match_on, :memo, :play_type,
                    results_attributes: [:id, :score, :point, :ie, :player_id, :rank]).
            merge(match_group_id: session[:mg])
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
