class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]
  before_action :prohibit_not_player_user, only: %i[ edit update destroy ]
  
  def index
    @players = player.all
  end
  
  def show
  end
  
  def new
    # @player = Player.new
    @form = Form::PlayerCollection.new
  end
  
  def create
    @form = Form::PlayerCollection.new(player_collection_params)
    
    
    if @form.save
      redirect_to '/', notice: "プレイヤーを選択しました"
    else
      flash.now[:alert] = "プレイヤー選択に失敗しました"
      render :new
    end
  end
    
  def edit
  end
  
  def update
    if @player.update(player_params)
      redirect_to player_path(@player), flash: {notice: "プレイヤー情報を更新しました"}
    else
      render :edit
    end
  end
  
  def destroy
    @player.destroy
    redirect_to players_url, flash: {notice: 'プレイヤーを削除しました'}
  end
  
  private 
  
    def set_player
      @player = Player.find(params[:id])  
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
