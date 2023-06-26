class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @sanyon_rules = {}
    @sanyon_rules[3] = Rule.sanma(params[:player_id])
    @sanyon_rules[4] = Rule.yonma(params[:player_id])
  end

  def show
  end

  def new
    set_rule_player
  end

  def create
    @rule = Rule.new(rule_params)
    if @rule.save
      # 成績登録０件の場合、新規成績登録ページへ
      unless @player.matches.exists?(play_type: @rule.play_type) 
        redirect_to new_match_path, flash: {notice: "ルール < #{@rule.name} > を登録しました"} and return 
      end
      redirect_to player_rules_path, flash: {notice: "ルール < #{@rule.name} > を登録しました"} and return
    else
      set_player
      render :new
    end
  end

  def edit
    redirect_to root_path, flash: {alert: 'ルール登録者でなければ、編集できません。'} and return unless current_player == @rule.player
    set_player
  end

  def update
    redirect_to root_path, flash: {alert: 'ルール登録者でなければ、更新できません。'} and return unless current_player == @rule.player

    if @rule.update(rule_params)
      redirect_to player_rules_path, flash: {notice: "ルール < #{@rule.name} > を編集しました"}
    else
      set_player
      render :edit
    end
  end

  def destroy
    redirect_to root_path, flash: {alert: 'ルール登録者でなければ、削除できません。'} and return unless current_player == @rule.player
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
      @rule.play_type = session_players_num #プレイヤー選択された人数を初期値とする
      set_player
      session[:players] = params[:players] unless params[:players].nil? #params[:players] → PlayersControllerのcreateアクションから受け取る
    end
  
    def rule_params
      params.require(:rule).
        permit(:play_type, :name, :mochi, :kaeshi, :uma_1, :uma_2, :uma_3, :uma_4, :score_decimal_point_calc, :is_chip, :chip_rate, :description).
        merge(player_id: current_player.id)
    end
end
