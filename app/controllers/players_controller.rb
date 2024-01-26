# frozen_string_literal: true

class PlayersController < ApplicationController
  before_action :set_player, only: [:show]
  before_action :authenticate_user!

  def show
    redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless current_player == @player
  end

  def new
    @play_type = params[:play_type]
    end_record if session[:league].present? && session[:mg].nil? # リーグ戦1局目登録中にプレイヤー選択に遷移した場合、セッションを解放する
    if params[:league].present?
      @league = League.find_by(id: params[:league])
      session[:league] = @league.id
      session[:rule] = @league.rule_id
    end
    # URLによる認証済みプレイヤーがいればセットする
    @authenticated_users = User.where(token_issued_user: current_user.id)

    played_player
    current_user.generate_authentication_url
    @authentication_url = players_authentications_url(tk: current_user.player_select_token, u_id: current_user.id)
  end

  def create
    session_players = create_or_find_players
    return if performed? # create_or_find_playersでリダイレクトされた場合、以降の処理を行わない

    session[:players] = session_players
    redirect_to_new_player_rule and return if current_player.rules.where(play_type: session_players_num).blank?
    redirect_to new_match_path and return unless session[:league].present?

    handle_league_play
  end

  private

  def set_player
    @player = Player.find_by(id: params[:id])
    redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @player
  end

  # 現在のプレイヤーがこれまでに遊んだプレイヤーのIDと名前を、最新のマッチから順に取得する
  def played_player
    match_ids = Result.where(player_id: current_player.id).pluck(:match_id)
    # current_playerがこれまで遊んだプレイヤーidと記録時間のhashを取得する (最近遊んだ順)
    hash_id_time = Result.where(match_id: match_ids)
                         .where.not(player_id: current_player.id)
                         .group(:player_id)
                         .maximum(:created_at)

    sorted_hash = hash_id_time.sort_by { |_, val| -val.to_i }
    p_ids = sorted_hash.map { |key, _| key } # player_idの配列
    p_names = p_ids.map { |p| Player.find(p).name }

    @played_players = p_ids.zip(p_names) # プレイヤー名とIDを格納
  end

  # リーグプレイヤーがすでに登録されているか
  def league_players_registered?
    l = League.find(session[:league])
    l.league_players.count == l.play_type # リーグプレイヤーが正しい人数登録されている場合true
  end

  def create_or_find_players
    unless params[:p_ids]
      redirect_to new_player_path(play_type: params[:play_type]),
                  alert: FlashMessages::FAIED_TO_SELECT_PLAYERS
    end
    session_players = []
    p_ids_names = params[:p_ids].map(&:to_i).zip(params[:p_names])

    p_ids_names.each do |id, name|
      if id.zero?
        new_player = Player.create(name: name)
        session_players << new_player
      else
        searched_player = Player.find_by(id: id, name: name)
        if searched_player.nil?
          redirect_to_new_player(p_ids_names.count)
          break
        end
        reset_token_issued_user(searched_player)
        session_players << searched_player
      end
    end

    session_players
  end

  def redirect_to_new_player(count)
    redirect_to new_player_path(play_type: count), alert: FlashMessages::FAIED_TO_SELECT_PLAYERS
  end

  def reset_token_issued_user(player)
    player.user&.update(token_issued_user: nil)
  end

  def redirect_to_new_player_rule
    redirect_to new_player_rule_path(current_player.id,
                                     previous_url: request.referer,
                                     play_type: session_players_num)
  end

  def handle_league_play
    LeaguePlayer.where(league_id: session[:league]).destroy_all if league_players_registered?
    LeaguePlayer.create(session[:players], session[:league])
    redirect_to new_match_path(league: session[:league])
  end
end
