class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  def show
    @sanyon_match_ids = {} # 三麻/四麻の成績表示のためのハッシュ
    match_ids = Result.where(player_id: params[:id]).pluck(:match_id)
    @sanyon_match_ids[3] = Match.sanma(match_ids).pluck(:id)   #三麻のmatch_idを配列で格納
    @sanyon_match_ids[4] = Match.yonma(match_ids).pluck(:id)   #四麻のmatch_idを配列で格納
  end
  
  def new
    @form = Form::PlayerCollection.new(params[:p_num].to_i)
    @error_player = Player.new
  end
  
  def create
    @form = Form::PlayerCollection.new(0 ,player_collection_params)

    if @form.save
      # ルール未登録の場合、ルール登録へ遷移
      set_session_players(@form)
      if current_player.rules.where(player_num: session_player_num).blank?
        redirect_to new_player_rule_path(current_player.id) 
      else
        redirect_to new_match_path
      end
    else
      @form.players.each do |player|
        @error_player = player unless player.errors.blank?
      end
      render :new
    end
  end
  
  private 
  
    def set_player
      @player = Player.find(params[:id])  
    end
    
    def set_session_players(form)
      session[:players] = form.session_players
    end
    
    def player_collection_params
        params.require(:form_player_collection)
        .permit(players_attributes: [:name, :user_id, :id])
    end
end
