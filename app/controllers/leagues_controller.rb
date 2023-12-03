class LeaguesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_league, only: [:show, :edit, :update, :destroy]

  def index
    league_player_ids = LeaguePlayer.where(player_id: current_player.id).pluck(:league_id) # current_playerが主催者でないが参加しているリーグ
    league_ids = League.where(player_id: current_player.id).pluck(:id) # current_playerが主催者のリーグ(league_player未選択の場合も抽出される)
    l_ids = (league_player_ids + league_ids).uniq
    @leagues = League.where(id: l_ids).order(created_at: :desc)
  end

  def show
    redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @league.league_players.exists?(player_id: current_player.id)
    @l_matches = Match.where(league_id: params[:id])
    @graph_datasets, @y_max, @y_min = @league.graph_data # 成績推移グラフのデータ
    @graph_labels =  @league.graph_label # 成績推移グラフの日付ラベル
    @rank_table_data = @league.rank_table(params[:id])  # 順位表のデータ
    @l_players = LeaguePlayer.where(league_id: params[:id]).order(:player_id)
  end

  def new
    set_player
    @league = League.new(player_id: @player.id)
  end

  def create
    @league = League.new(league_params)
    redirect_to root_path, alert: FlashMessages::FAILED_TO_CREATE_LEAGUE and return unless current_player.id == @league.player_id
    if @league.save
      set_session_league
      redirect_to new_player_path(play_type: @league.play_type, league: @league.id), notice: FlashMessages::league_flash(@league.name, "create") and return
    else
      set_player
      render :new
    end
  end

  def edit
    redirect_to root_path, alert: FlashMessages::CANNOT_EDIT_LEAGUE and return unless @league.player_id == current_player.id
  end

  def update
    redirect_to root_path, alert: FlashMessages::CANNOT_UPDATE_LEAGUE and return unless @league.player_id == current_player.id
    if @league.update(league_params)
      redirect_to league_path(@league), notice: FlashMessages::league_flash(@league.name, "update") and return
    else
      render :edit
    end
  end

  def destroy
    redirect_to root_path, alert: FlashMessages::CANNOT_DESTROY_LEAGUE and return unless @league.player_id == current_player.id

    if @league
      @league.destroy
      redirect_to leagues_path, notice: FlashMessages::league_flash(@league.name, "destroy") and return
    else
      redirect_to leagues_path, alert: FlashMessages::FAILED_TO_DESTROY_LEAGUE and return
    end
  end

  private

    def set_league
      @league = League.find_by(id: params[:id])
      redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @league
    end

    def set_player
      @player = current_player
      redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @player
    end

    def set_session_league
      session[:league] = @league.id
      session[:rule] = @league.rule_id
    end

    def league_params
      params.require(:league).permit(:name, :play_type, :rule_id, :description).
        merge(player_id: current_player.id)
    end
end
