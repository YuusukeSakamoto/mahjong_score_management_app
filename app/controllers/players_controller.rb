class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]

  def index
    @players = player.all
  end
  
  def show
    @result = Result.new
  end
  
  def new
    @form = Form::PlayerCollection.new
    @error_player = Player.new
  end
  
  def create
    @form = Form::PlayerCollection.new(player_collection_params)

    if @form.save
      # プレイヤーID未登録またはルール未登録の場合、ルール登録へ遷移
      if current_user.player.nil? || current_user.player.rules.blank?
        set_session_players(@form)
        redirect_to new_player_rule_path(current_user.player.id) 
      else
        set_session_players(@form)
        redirect_to new_match_path
      end
    else
      @form.players.each do |player|
        # byebug
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
