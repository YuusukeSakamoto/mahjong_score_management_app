class RulesController < ApplicationController
  before_action :set_rule, only: [:edit, :update, :destroy]
  before_action :set_player, only: [:create, :edit]
  before_action :authenticate_user!

  def index
    redirect_to root_path , alert: FlashMessages::ACCESS_DENIED and return unless current_player.id == params[:player_id].to_i
    @sanyon_rules = {}
    @sanyon_rules[3] = Rule.sanma(params[:player_id])
    @sanyon_rules[4] = Rule.yonma(params[:player_id])
  end

  def new
    redirect_to root_path , alert: FlashMessages::ACCESS_DENIED and return unless current_player.id == params[:player_id].to_i
    session[:previous_url] = params[:previous_url] if params[:previous_url] # ここで遷移元をセッションを保存
    set_rule_player
  end

  def create
    redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless current_player == @player
    previous_url = session[:previous_url]
    session[:previous_url] = nil
    @rule = Rule.new(rule_params)
    if @rule.save
      redirect_to player_rules_path,notice: FlashMessages.rule_flash(@rule.name, "create") and return if previous_url.nil?
      if previous_url.include?(new_player_path)
        redirect_to new_match_path, notice: FlashMessages.rule_flash(@rule.name, "create") and return
      else
        redirect_to previous_url, notice: FlashMessages.rule_flash(@rule.name, "create") and return  # create後に遷移させる
      end
    else
      render :new
    end
  end

  def edit
    redirect_to root_path, alert: FlashMessages::EDIT_DENIED and return unless current_player == @rule.player
    @is_match = Match.exists?(rule_id: @rule.id)
  end

  def update
    redirect_to root_path, alert: FlashMessages::UPDATE_DENIED and return unless current_player == @rule.player

    if @rule.update(rule_params)
      redirect_to player_rules_path, notice: FlashMessages.rule_flash(@rule.name, "update") and return
    else
      set_player
      render :edit
    end
  end

  def destroy
    redirect_to root_path, alert: FlashMessages::DESTROY_DENIED and return unless current_player == @rule.player
    redirect_to player_rules_path, alert: FlashMessages::DELETION_PREVENTED_DUE_TO_ASSOCIATED_RECORDS and return if Match.exists?(rule_id: @rule.id)

    if @rule
      @rule.destroy
      redirect_to player_rules_path, notice: FlashMessages::rule_flash(@rule.name, "destroy") and return
    else
      redirect_to root_path, alert: FlashMessages::CANNOT_DESTROY and return
    end
  end

  private

    def set_rule
      @rule = Rule.find_by(id: params[:id])
      redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @rule
    end

    def set_player
      @player = Player.find_by(id: params[:player_id])
      redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @player
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

    #ログインプレイヤーが登録したルールかどうかを判定する
    def current_player_rule?
      @current_player ||= Player.find_by(id: params[:player_id])
    end
end
