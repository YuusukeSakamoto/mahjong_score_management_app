class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @rules = Rule.all
  end

  def show
  end

  def new
    set_rule_player
    # set_session_players unless params[:players].nil?
  end

  def create
    @rule = Rule.new(rule_params)
    # byebug
    if @rule.save
      redirect_to '/'
    else
      @player = Player.find(params[:player_id])
      render :new
    end
  end

  def edit
    redirect_to root_path, flash: {alert: '投稿者でなければ、編集できません。'} and return unless current_user == @rule.user
  end

  def update
    redirect_to root_path, flash: {alert: '投稿者でなければ、更新できません。'} and return unless current_user == @rule.user

    if @rule.update(rule_params)
      redirect_to rule_path(@rule), flash: {notice: "投稿を編集しました。"}
    else
      render :edit
    end
  end

  def destroy
    redirect_to root_path, flash: {alert: '投稿者でなければ、削除できません。'} and return unless current_user == @rule.user

    @rule.destroy

    redirect_to rules_path, flash: {notice: "投稿を削除しました。"}
  end

  private
  
    def set_rule
      @rule = Rule.find(params[:id])
    end
    
    def set_rule_player
      @rule = Rule.new
      @player = Player.find(params[:player_id])
      session[:players] = params[:players] unless params[:players].nil? #params[:players] → PlayersControllerのcreateアクションから受け取る
    end
    
    # def set_session_players
    #   session[:players] = params[:players] #params[:players] → PlayersControllerのcreateアクションから受け取る
    # end
  
    def rule_params
      params.require(:rule).
        permit(:name, :mochi, :kaeshi, :uma_1, :uma_2, :uma_3, :uma_4, :score_decimal_point_calc, :chip_existence_flag, :chip_rate, :description).
        merge(player_id: current_user.player.id)
    end
end
