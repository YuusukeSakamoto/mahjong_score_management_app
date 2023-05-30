class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @rules = Rule.all.where(player_id: params[:player_id])
  end

  def show
  end

  def new
    set_rule_player
  end

  def create
    @rule = Rule.new(rule_params)
    if @rule.save
      redirect_to new_match_path
    else
      set_player
      render :new
    end
  end

  def edit
    set_player
  end

  def update
    # redirect_to root_path, flash: {alert: '投稿者でなければ、更新できません。'} and return unless current_user == @rule.user

    if @rule.update(rule_params)
      redirect_to player_rules_path, flash: {notice: "ルール < #{@rule.name} > を編集しました"}
    else
      set_player
      render :edit
    end
  end

  def destroy
    # redirect_to root_path, flash: {alert: '投稿者でなければ、削除できません。'} and return unless current_user == @rule.user
    @rule.destroy
    redirect_to player_rules_path, flash: {notice: "ルール < #{@rule.name} > を削除しました"}
  end

  private
  
    def set_rule
      @rule = Rule.find(params[:id])
    end
    
    def set_player
      @player = Player.find(params[:player_id])
    end
    
    def set_rule_player
      @rule = Rule.new
      set_player
      session[:players] = params[:players] unless params[:players].nil? #params[:players] → PlayersControllerのcreateアクションから受け取る
    end
  
    def rule_params
      params.require(:rule).
        permit(:name, :mochi, :kaeshi, :uma_1, :uma_2, :uma_3, :uma_4, :score_decimal_point_calc, :is_chip, :chip_rate, :description).
        merge(player_id: current_user.player.id)
    end
end
