class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy]
  before_action :set_player, only: [:create, :edit]
  before_action :authenticate_user!

  def index
    @sanyon_rules = {}
    @sanyon_rules[3] = Rule.sanma(params[:player_id])
    @sanyon_rules[4] = Rule.yonma(params[:player_id])
  end

  def show
  end

  def new
    session[:previous_url] = params[:previous_url] if params[:previous_url] # ここで遷移元をセッションを保存
    set_rule_player
  end

  def create
    previous_url = session[:previous_url]
    session[:previous_url] = nil
    @rule = Rule.new(rule_params)
    if @rule.save
      redirect_to player_rules_path, notice: "ルール : #{@rule.name}を登録しました" and return if previous_url.nil?
      if previous_url.include?(new_player_path)
        redirect_to new_match_path, notice: "ルール : #{@rule.name}を登録しました" and return 
      else
        redirect_to previous_url, notice: "ルール : #{@rule.name}を登録しました" and return  # create後に遷移させる
      end
    else
      render :new
    end
  end

  def edit
    redirect_to root_path, alert: 'ルール登録者でなければ、編集できません' and return unless current_player == @rule.player
    @is_match = Match.exists?(rule_id: @rule.id)
  end

  def update
    redirect_to root_path, alert: 'ルール登録者でなければ、更新できません' and return unless current_player == @rule.player

    if @rule.update(rule_params)
      redirect_to player_rules_path, notice: "ルール : #{@rule.name}を編集しました"
    else
      set_player
      render :edit
    end
  end

  def destroy
    redirect_to root_path, alert: 'ルール登録者でなければ、削除できません' and return unless current_player == @rule.player
    redirect_to player_rules_path, alert: '指定したルールで記録した成績が存在するため、削除できません' and return if Match.exists?(rule_id: @rule.id)

    if @rule
      @rule.destroy
      redirect_to player_rules_path, notice: "ルール : #{@rule.name}を削除しました" and return
    else
      redirect_to root_path, alert: "削除できませんでした" and return
    end
  end

  private
  
    def set_rule
      @rule = Rule.find_by(id: params[:id])
    end
    
    def set_player
      @player = Player.find_by(id: params[:player_id])
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
