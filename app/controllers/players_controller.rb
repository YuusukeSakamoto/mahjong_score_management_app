class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]
  before_action :prohibit_not_player_user, only: %i[ edit update destroy ]
  
  def index
    @players = player.all
  end
  
  def show
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
        @error_player = player unless player.errors.blank?
      end
      render :new
    end
  end
    
  def edit
  end
  
  def update
    if @player.update(player_params)
      redirect_to player_path(@player), flash: {notice: "プレイヤー < #{@player.name} > の情報を更新しました"}
    else
      render :edit
    end
  end
  
  def destroy
    @player.destroy
    redirect_to players_url, flash: {notice: "プレイヤー < #{@player.name} > を削除しました"}
  end
  
  private 
  
    def set_player
      @player = Player.find(params[:id])  
    end
    
    def set_session_players(form)
      session[:players] = form.session_players
    end
    
    def player_params
      params.require(:player).permit(:name, :member_count).merge(user_id: current_user.id)
    end
    
    #プレイヤーユーザー以外のアクセスを禁止する
    def prohibit_not_player_user
      redirect_to root_path, 
      flash: {alert: 'プレイヤーでなければ、編集できません。'} and return unless current_user == @player.user
    end
    
    def player_collection_params
        params.require(:form_player_collection)
        .permit(players_attributes: [:name, :user_id, :id])
    end
end
