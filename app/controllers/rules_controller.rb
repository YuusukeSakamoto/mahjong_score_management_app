# frozen_string_literal: true

class RulesController < ApplicationController
  before_action :set_rule, only: %i[edit update destroy]
  before_action :set_player, only: %i[create edit]
  before_action :authenticate_user!

  def index
    unless current_player.id == params[:player_id].to_i
      redirect_to(root_path,
                  alert: FlashMessages::ACCESS_DENIED) && return
    end

    @sanyon_rules = {}
    @sanyon_rules[3] = Rule.sanma(params[:player_id])
    @sanyon_rules[4] = Rule.yonma(params[:player_id])
  end

  def new
    if recording?
      redirect_to(root_path,
                  alert: FlashMessages::CANNOT_CREATE_RULE_RECORDING)
    end
    unless current_player.id == params[:player_id].to_i
      redirect_to(root_path,
                  alert: FlashMessages::ACCESS_DENIED) && return
    end

    session[:previous_url] = params[:previous_url] if params[:previous_url] # ここで遷移元をセッションを保存
    session[:previous_url] = nil if params[:btn] == 'header' || params[:btn] == 'index' # ヘッダーとルール一覧から遷移はセッション(前ページ)を削除
    set_rule_player
  end

  def create
    redirect_to(root_path, alert: FlashMessages::ACCESS_DENIED) and return unless current_player == @player

    previous_url = session[:previous_url]
    session[:previous_url] = nil
    @rule = Rule.new(rule_params)
    return render :new unless @rule.save

    notice_message = FlashMessages.rule_flash(@rule.name, 'create')
    redirect_to(player_rules_path, notice: notice_message) and return if previous_url.nil?
    redirect_to(new_match_path, notice: notice_message) and return if previous_url.include?(new_player_path)
    if previous_url.include?(new_league_path)
      redirect_to(new_league_path(rule: @rule.id, play_type: @rule.play_type),
                  notice: notice_message) and return
    end

    redirect_to(previous_url, notice: notice_message) and return
  end

  def edit
    redirect_to(root_path, alert: FlashMessages::EDIT_DENIED) && return unless current_player == @rule.player

    @is_match = Match.exists?(rule_id: @rule.id)
    @is_league = League.exists?(rule_id: @rule.id)
  end

  def update
    redirect_to(root_path, alert: FlashMessages::UPDATE_DENIED) && return unless current_player == @rule.player

    if @rule.update(rule_params)
      redirect_to(player_rules_path, notice: FlashMessages.rule_flash(@rule.name, 'update')) && return
    end

    set_player
    render :edit
  end

  def destroy
    redirect_to(root_path, alert: FlashMessages::DESTROY_DENIED) && return unless current_player == @rule.player
    if Match.exists?(rule_id: @rule.id)
      redirect_to(player_rules_path,
                  alert: FlashMessages::DELETION_PREVENTED_DUE_TO_ASSOCIATED_RECORDS) && return
    end

    redirect_to(root_path, alert: FlashMessages::CANNOT_DESTROY) && return unless @rule

    redirect_to(root_path, alert: FlashMessages::CANNOT_DESTROY) && return unless @rule.destroy

    redirect_to(player_rules_path, notice: FlashMessages.rule_flash(@rule.name, 'destroy')) && return
  end

  private

  def set_rule
    @rule = Rule.find_by(id: params[:id])
    redirect_to(root_path, alert: FlashMessages::ACCESS_DENIED) && return unless @rule
  end

  def set_player
    @player = Player.find_by(id: params[:player_id])
    redirect_to(root_path, alert: FlashMessages::ACCESS_DENIED) && return unless @player
  end

  def set_rule_player
    @rule = Rule.new(play_type: params[:play_type]) # プレイヤー選択された人数を初期値とする
    # @rule.play_type = session_players_num
    set_player
    # params[:players] → PlayersControllerのcreateアクションから受け取る
    session[:players] = params[:players] unless params[:players].nil?
  end

  def rule_params
    params.require(:rule)
          .permit(:play_type, :name, :mochi, :kaeshi,
                  :uma_one, :uma_two, :uma_three, :uma_four,
                  :score_decimal_point_calc,
                  :is_chip, :chip_rate, :description)
          .merge(player_id: current_player.id)
  end

  # ログインプレイヤーが登録したルールかどうかを判定する
  def current_player_rule?
    @current_player_rule ||= Player.find_by(id: params[:player_id])
  end
end
