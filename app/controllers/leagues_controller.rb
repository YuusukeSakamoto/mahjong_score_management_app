class LeaguesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_league, only: [:show, :edit, :update, :destroy]

  def index
    @leagues = League.where(player_id: current_player.id)
  end
  
  def show
    @rank_table_data = @league.rank_table
    @graph_labels =  @league.graph_label
    @graph_datasets, @y_max, @y_min = @league.graph_data
    @l_players = LeaguePlayer.where(league_id: params[:id]).order(:player_id)
    mg_ids = @league.match_groups.pluck(:id)
    @l_matches = Match.league(mg_ids)
  end
  
  def new
    @player = Player.find(params[:p_id])
    @league = League.new(player_id: params[:p_id])
  end
  
  def create
    @league = League.new(league_params)
    if @league.save
      set_session_league
      redirect_to new_player_path(play_type: @league.play_type), flash: {notice: "次に参加プレイヤーを登録してください"}
    else
      @player = Player.find(@league.player_id)
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @league.update(league_params)
      redirect_to leagues_path(@league), notice: "#{@league.name}のリーグ情報を更新しました"
    else
      render :edit
    end
  end
  
  def destroy
    @league.destroy
    redirect_to leagues_path, notice: "リーグ< #{@league.name} >を削除しました"
  end
  
  private
  
    def set_league
      @league = League.find(params[:id])
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
